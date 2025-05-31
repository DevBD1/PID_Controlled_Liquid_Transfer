pkg load instrument-control;

% --- Seri bağlantı ---
s = serialport("COM3", 9600);
s.Timeout = 2;
pause(2);
disp("COM3 bağlantısı kuruldu.");

% --- Ölçüm sayısı kullanıcıdan alınır ---
n = input("Kaç adet ölçüm alınsın? ");

% --- Dosya adı çakışma kontrolü ---
base_filename = "log_static.csv";
filename = base_filename;
counter = 2;
while exist(filename, "file")
    filename = sprintf("log_static_%d.csv", counter);
    counter += 1;
end

f = fopen(filename, "w");
fprintf("Kayıt dosyası: %s\n", filename);

fprintf("%d ölçüm alınacak...\n", n);

for i = 1:n
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

fclose(f);
clear s;
disp("Ölçüm tamamlandı.");
