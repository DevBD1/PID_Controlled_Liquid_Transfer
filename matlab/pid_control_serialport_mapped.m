% PID kontrol Octave tarafında yapılır
pkg load instrument-control;

% --- Seri port bağlantısı ---
s = serialport("COM3", 9600);
s.Timeout = 1;  % saniye cinsinden
pause(2);
disp("✅ COM3 bağlantısı kuruldu.");

% --- İlk ölçüm ---
flush(s);               % Buffer temizle
writeline(s, "M");   % Komutu gönder
pause(0.05);            % Cevap için bekle

try
    mesafe_raw = readline(s);
    fprintf("📥 Gelen veri: %s\n", mesafe_raw);

    first_distance = str2double(strtrim(mesafe_raw));
    fprintf("📏 İlk Ölçüm (Mesafe): %.2f cm\n", first_distance);
catch
    warning("❌ Veri alınamadı! Arduino cevap vermedi.");
    first_distance = NaN;
end

% --- Hedef mesafe kullanıcıdan alınır ---
target = input("🎯 Lütfen hedef mesafeyi cm cinsinden giriniz: ");

% PID toleransını dosyadan oku
if exist("pid_tolerance.mat", "file")
    load("pid_tolerance.mat", "tolerance_mm");
    tolerance = tolerance_mm / 10;  % mm → cm dönüşümü gerekiyorsa
    fprintf("🔧 PID toleransı dosyadan yüklendi: ±%.2f mm (%.2f cm)\n", tolerance_mm, tolerance);
else
    warning("⚠️ Tolerans dosyası bulunamadı, varsayılan değer kullanılacak.");
    tolerance = target * 0.05;
end

fprintf("📐 Hedef Mesafe: %.2f cm (+/- %.2f cm)\n", target, tolerance);

% --- PID sabitleri ---
Kp = 40; Ki = 0.5; Kd = 20;
integral = 0;
prev_err  = 0;
prev_time = time();

% --- PWM sınırları ---
MIN_PWM = 96;
MAX_PWM = 255;
outputMax = 100;  % PID çıkışının maksimum beklenen değeri

% --- Log dosyası ---
log_filename = "pid_log.csv";
log_file = fopen(log_filename, "w");
fprintf(log_file, "timestamp,distance,status,pwm,command\n");

unwind_protect
  disp("📡 Veri alınıyor ve PID uygulanıyor...");

  while true
    disp("🔁 Döngü başladı...");
    try
        flush(s);  % seri buffer'ı temizle
        writeline(s, "M");    % Ölçüm iste
        pause(0.01);  % Arduino'ya yeni değer yollama zamanı ver
        raw = readline(s);    % Arduino bu komutta mesafe ölçsün ve göndersin
        distance = str2double(strtrim(raw));

        if isnan(distance)
            writeline(s, "S000");
            pause(0.5);
            continue;
        end

        if distance < 2 || distance > 30
            writeline(s, "S000");
            pause(0.5);
            continue;
        end

        now = time();
        dt = now - prev_time;
        err =  distance - target;
        integral += err * dt;
        derivative = (err - prev_err) / dt;
        output = Kp * err + Ki * integral + Kd * derivative;

        prev_err = err;
        prev_time = now;

        % PWM mapping
        raw_output = abs(output);
        clipped = min(raw_output, outputMax);
        pwm = round((clipped / outputMax) * (MAX_PWM - MIN_PWM) + MIN_PWM);

        if abs(err) <= tolerance
            cmd = "S000";
            status = "Denge (Stop)";
            pwm = 0;
        elseif output > 0
            cmd = sprintf("F%03d", pwm);
            status = "Dolum (A->B)";
        else
            cmd = sprintf("R%03d", pwm);
            status = "Tahliye (B->A)";
        end

        writeline(s, cmd);
        printf("Mesafe: %.2f cm | Durum: %s | Komut: %s\n", distance, status, cmd);
        fprintf(log_file, "%s,%.2f,%s,%d,%s\n", datestr(now, "HH:MM:SS"), distance, status, pwm, cmd);

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
