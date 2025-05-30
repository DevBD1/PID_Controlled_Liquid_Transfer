pkg load instrument-control;

% --- Seri bağlantı başlat ---
s = serialport("COM3", 9600);
s.Timeout = 2;
pause(2);
disp("✅ COM3 bağlantısı kuruldu.");

% --- Ölçüm sayısı kullanıcıdan alınır ---
n = input("📥 Kaç adet ölçüm alınsın? ");

% --- Yön seçimi: Dolum mu Tahliye mi? ---
dir = "";
while ~any(strcmp(dir, {"F", "R"}))
    dir_input = input("🚰 Pompa yönünü seç (F = Dolum, R = Tahliye): ", "s");
    dir = upper(strtrim(dir_input));
end

% --- Dosya adı oluştur ---
base_filename = "standart_sapma_pid.csv";
filename = base_filename;
counter = 2;
while exist(filename, "file")
    filename = sprintf("standart_sapma_pid-%d.csv", counter);
    counter += 1;
end

f = fopen(filename, "w");
fprintf("💾 Kayıt dosyası: %s\n", filename);

% --- Pompa başlat ---
cmd = strcat(dir, "128");
writeline(s, cmd);
if dir == "F"
    yon_etiketi = "Dolum";
else
    yon_etiketi = "Tahliye";
end
fprintf("🟢 Pompa çalışıyor (%s)...\n", yon_etiketi);

pause(3);  % sistem otursun

% --- Ölçüm başlasın ---
fprintf("🔁 %d adet ölçüm başlatılıyor...\n", n);
for i = 1:n
    flush(s);
    writeline(s, "M");
    pause(0.05);
    try
        raw = readline(s);
        value = str2double(strtrim(raw)) * 10;  % cm → mm
        if isnan(value) || value < 10 || value > 300
            warning("⚠️ Geçersiz değer: %s", raw);
            continue;
        end
        fprintf(f, "%.2f\n", value);
        fprintf("📏 Ölçüm %03d: %.2f mm\n", i, value);
    catch
        warning("❌ Okuma hatası.");
    end
    pause(0.05);
end

% --- Pompa durdur ---
writeline(s, "S000");
disp("🛑 Pompa durduruldu.");

fclose(f);
clear s;
disp("✅ Ölçüm tamamlandı.");
