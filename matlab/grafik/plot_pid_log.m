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

  fgetl(fid); % başlığı atla

  time_s = [];
  level_mm = [];

  first_time = [];

  while ~feof(fid)
    line = fgetl(fid);
    parts = strsplit(line, ",");

    if length(parts) < 3
      continue;
    end

    timestamp_str = parts{1};
    level_str = parts{3};

    try
      t = datenum(timestamp_str, "HH:MM:SS");
      if isempty(first_time)
        first_time = t;
      end
      time_val = (t - first_time) * 86400; % gün → saniye
      level_val = str2double(level_str);

      if !isnan(time_val) && !isnan(level_val)
        time_s(end+1) = time_val;
        level_mm(end+1) = level_val;
      end
    catch
      % geçersiz satırı atla
    end
  endwhile

  fclose(fid);

  % Grafik çiz
  figure;
  plot(time_s, level_mm, "-o");
  xlabel("Zaman (s)");
  ylabel("Sıvı Seviyesi (mm)");
  title("PID Kontrollü Sıvı Seviyesi Değişimi");
  grid on;
end
