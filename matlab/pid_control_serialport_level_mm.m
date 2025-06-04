% PID kontrol Octave tarafında yapılır
pkg load instrument-control;

% --- Seri port bağlantısı ---
s = serialport("/dev/tty.usbserial-10", 9600);
% s = serialport("COM3", 9600);
s.Timeout = 1;  % saniye cinsinden
pause(2);
disp("✅ USB bağlantısı kuruldu.");

% --- Fiziksel ölçüler ---
sensor_height_mm = 135;  % sensör yüksekliği, kap bosken yapilan olcum sonucu
max_liquid_mm = 100;     % maksimum sıvı seviyesi

% --- İlk ölçüm ---
writeline(s, "M");
pause(0.05);

try
    mesafe_raw = readline(s);
    fprintf("📥 Gelen veri: %s\n", mesafe_raw);

    distance_cm = str2double(strtrim(mesafe_raw));
    distance_mm = distance_cm * 10;  
    level_mm = sensor_height_mm - distance_mm;
    fprintf("📏 İlk Ölçüm: %.2f mm | Sıvı Seviyesi: %.2f mm\n", distance_mm, level_mm);
catch
    warning("❌ Veri alınamadı! Arduino cevap vermedi.");
    level_mm = NaN;
end

% --- Hedef seviye kullanıcıdan alınır ---
target = input("🎯 Lütfen hedef sıvı seviyesini mm cinsinden giriniz: ");

% PID toleransını dosyadan oku
if exist("pid_tolerance.mat", "file")
    load("pid_tolerance.mat", "tolerance_mm");
    fprintf("🔧 PID toleransı dosyadan yüklendi: ±%.2f mm\n", tolerance_mm);
else
    warning("⚠️ Tolerans dosyası bulunamadı, varsayılan değer kullanılacak.");
    tolerance_mm = target * 0.05;
end

fprintf("📐 Hedef Sıvı Seviyesi: %.2f mm (+/- %.2f mm)\n", target, tolerance_mm);

% --- PID sabitleri ---
Kp = 10; Ki = 0.2; Kd = 5;;
integral = 0;
prev_err  = 0;
prev_time = time();

% --- PWM sınırları ---
MIN_PWM = 96;
MAX_PWM = 255;
outputMax = 100;

% --- Log dosyası ---
log_filename = "pid_log_level.csv";
log_file = fopen(log_filename, "w");
fprintf(log_file, "timestamp,distance_mm,level_mm,status,pwm,command\n");

unwind_protect
  disp("📡 Veri alınıyor ve PID uygulanıyor...");

  while true
    try
        flush(s);
        writeline(s, "M");
        pause(0.01);
        raw = readline(s);
        distance_cm = str2double(strtrim(raw));
        distance_mm = distance_cm * 10;
        level_mm = sensor_height_mm - distance_mm;

        if isnan(distance_cm)
            writeline(s, "S000");
            pause(0.5);
            continue;
        end

        if distance_mm < 20 || distance_mm > 300
            writeline(s, "S000");
            pause(0.5);
            continue;
        end

        now = time();
        dt = now - prev_time;
        err = level_mm - target;
        integral += err * dt;
        derivative = (err - prev_err) / dt;
        output = Kp * err + Ki * integral + Kd * derivative;

        prev_err = err;
        prev_time = now;

        raw_output = abs(output);
        clipped = min(raw_output, outputMax);
        pwm = round((clipped / outputMax) * (MAX_PWM - MIN_PWM) + MIN_PWM);

        if abs(err) <= tolerance_mm
            cmd = "S000";
            status = "Denge (Stop)";
            pwm = 0;
        else
          raw_output = abs(output);
          clipped = min(raw_output, outputMax);
          pwm_mapped = round((clipped / outputMax) * MAX_PWM);  % 0–255 arası

        % Sadece anlamlı PWM değerlerini kullanalım
        if pwm_mapped < MIN_PWM
            pwm = 0;
        else
            pwm = pwm_mapped;
        end

        if output > 0
            cmd = sprintf("R%03d", pwm);
            status = "Tahliye (B->A)";
        else
            cmd = sprintf("F%03d", pwm);
            status = "Dolum (A->B)";
        end
    end

        writeline(s, cmd);
        printf("Seviye: %.2f mm | Durum: %s | Komut: %s\n", level_mm, status, cmd);
        fprintf(log_file, "%s,%.2f,%.2f,%s,%d,%s\n", datestr(now, "HH:MM:SS"), distance_mm, level_mm, status, pwm, cmd);

        pause(0.5);
    catch pid_err
        break;
    end
  endwhile

unwind_protect_cleanup
  writeline(s, "S000");
  fclose(log_file);
  clear s;
end_unwind_protect
