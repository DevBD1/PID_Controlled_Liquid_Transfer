pkg load instrument-control;

% --- Seri bağlantı başlat ---
s = serialport("COM3", 9600);
s.Timeout = 2;
pause(2);
disp("✅ COM3 bağlantısı kuruldu.");

% --- Ölçüm sayısı kullanıcıdan alınır ---
n = input("Kaç adet ölçüm alınsın? ");

% --- Dosya adı oluştur ---
base_filename = "log_realistic.csv";
filename = base_filename;
counter = 2;
while exist(filename, "file")
    filename = sprintf("log_realistic_%d.csv", counter);
    counter += 1;
end

f = fopen(filename, "w");
fprintf("Kayıt dosyası: %s\n", filename);

pause(3);  % sistem dengelensin

% --- Ölçüm başlasın ---
fprintf("%d adet ölçüm başlatılıyor (1s dolum / 1s tahliye)...\n", n);

for i = 1:n
    flush(s);

    % Alternatif komut: her seferinde yön değiştir
    if mod(i, 2) == 1
        writeline(s, "F128");  % 1 saniye dolum
    else
        writeline(s, "R128");  % 1 saniye tahliye
    end

    pause(1);  % pompa çalışsın

    % Ölçüm komutu gönder ve oku
    flush(s);
    writeline(s, "M");
    pause(0.05);
    try
        raw = readline(s);
        value = str2double(strtrim(raw)) * 10;  % cm → mm
        if isnan(value) || value < 10 || value > 300
            warning("Geçersiz değer: %s", raw);
            continue;
        end
        fprintf(f, "%.2f\n", value);
        fprintf("Ölçüm %03d: %.2f mm\n", i, value);
    catch
        warning("Okuma hatası.");
    end

    pause(0.05);
end

% --- Pompa durdur ---
writeline(s, "S000");
disp("Pompa durduruldu.");

fclose(f);
clear s;
disp("Ölçüm tamamlandı.");
