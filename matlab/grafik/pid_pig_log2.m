function plot_pid_log(filename)
  if nargin < 1
    filename = "pid_log_level.csv";
  end

  if ~exist(filename, "file")
    error("❌ Dosya bulunamadı: %s", filename);
  end

  fid = fopen(filename, "r");
  if fid == -1
    error("❌ Dosya açılamadı: %s", filename);
  end

  fgetl(fid); % başlık satırını atla

  time_s = [];
  level_mm = [];
  pwm_vals = [];

  first_time = [];

  while ~feof(fid)
    line = fgetl(fid);
    parts = strsplit(line, ",");

    if length(parts) < 5
      continue;
    end

    timestamp_str = parts{1};
    level_str = parts{3};
    pwm_str = parts{5};

    try
      t = datenum(timestamp_str, "HH:MM:SS");
      if isempty(first_time)
        first_time = t;
      end
      time_val = (t - first_time) * 86400;  % saniyeye çevir
      level_val = str2double(level_str);
      pwm_val = str2double(pwm_str);

      if !isnan(time_val) && !isnan(level_val) && !isnan(pwm_val)
        time_s(end+1) = time_val;
        level_mm(end+1) = level_val;
        pwm_vals(end+1) = pwm_val;
      end
    catch
      continue;
    end
  endwhile

  fclose(fid);

  % PWM'yi normalize et (0–1 arası)
  pwm_norm = pwm_vals / 255 * (max(level_mm) - min(level_mm)) + min(level_mm);

  figure;
  plot(time_s, level_mm, "-o", "LineWidth", 2);
  hold on;
  plot(time_s, pwm_norm, "--", "LineWidth", 1.5);
  hold off;

  xlabel("Zaman (s)");
  ylabel("Sıvı Seviyesi (mm) (PWM normalize)");
  legend("Sıvı Seviyesi", "PWM (ölçeklenmiş)");
  title("PID Kontrollü Sıvı Seviyesi ve PWM");
  grid on;
end
