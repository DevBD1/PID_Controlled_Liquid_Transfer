% --- Kullanıcıdan analiz edilecek dosya ismini al ---
filename = input("📂 Lütfen analiz edilecek CSV dosyasının adını giriniz (örnek: standart_sapma.csv): ", "s");

% --- Dosya kontrolü ---
if ~exist(filename, "file")
    error("❌ Dosya bulunamadı: %s", filename);
end

% --- Veriyi oku ve temizle ---
data = load(filename);
data = data(data > 0);  % negatif ya da sıfırları at

% --- Temel istatistikler ---
mean_val = mean(data);
std_val  = std(data);
max_val  = max(data);
min_val  = min(data);
max_dev  = max(abs(data - mean_val));
error_rate = (max_dev / mean_val) * 100;

% --- Optimum tolerans olarak standart sapmayı kullan ---
tolerance_mm = std_val;
save("pid_tolerance.mat", "tolerance_mm");

% --- Sonuçları yazdır ---
fprintf("\n📊 ANALİZ SONUÇLARI (%s için):\n", filename);
fprintf("• Ölçüm Sayısı        : %d\n", length(data));
fprintf("• Ortalama Mesafe     : %.2f mm\n", mean_val);
fprintf("• Maksimum Sapma      : %.2f mm\n", max_dev);
fprintf("• Yüzde Hata          : %.2f %%\n", error_rate);
fprintf("• Standart Sapma      : %.2f mm\n", std_val);
fprintf("• Optimum Tolerans    : ±%.2f mm\n", tolerance_mm);
