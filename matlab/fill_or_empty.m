% Manuel yön kontrolü yapan Octave scripti
pkg load instrument-control;

% --- Seri port bağlantısı ---
s = serialport("COM3", 9600);
pause(2);
disp("✅ COM3 bağlantısı kuruldu.");

% --- Kullanıcıdan yön bilgisi al ---
dir_input = upper(input("🚰 Pompa yönünü seç (F = Dolum, R = Tahliye): ", "s"));

if dir_input != "F" && dir_input != "R"
  disp("❌ Hatalı giriş. Yalnızca F veya R kabul edilir.");
  clear s;
  return;
end

% --- Komutu hazırla ve gönder ---
cmd = sprintf("%s255", dir_input);
fprintf("🔁 Pompa %s yönünde çalışıyor (PWM = 255).\n", dir_input);

unwind_protect
  while true
    writeline(s, cmd);
    fprintf("Komut gönderildi: %s\n", cmd);
    pause(0.5);
  endwhile

unwind_protect_cleanup
  writeline(s, "S000");
  disp("🛑 Pompa durduruldu.");
  clear s;
end_unwind_protect
