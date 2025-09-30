require 'find'
require 'digest'
require 'json'

#Вычисление хеша
def get_file_hash(file_path)
  digest = Digest::SHA256.new
  File.open(file_path, 'rb') do |f|
    while chunk = f.read(1024 * 1024) # 1MB за раз
      digest.update(chunk)
    end
  end
  digest.hexdigest
end

#Сбор данных про файлы
def scan_files(root_dir)
  files_data = []
  Find.find(root_dir) do |path|
    next if File.directory?(path) # Пропустити директорії
    file_info = {
      path: path,
      size: File.size(path),
      inode: File.stat(path).ino
    }
    files_data << file_info
  end
  files_data
end

#Группирование по хешам
def group_duplicates(files_data)
  file_hashes = Hash.new { |hash, key| hash[key] = [] }
  files_data.each do |file|
    hash = get_file_hash(file[:path])
    file_hashes[hash] << file
  end
  file_hashes.select { |hash, files| files.size > 1 }
end
# Отчет
def generate_report(duplicates)
  groups = duplicates.map do |hash, files|
    size_bytes = files.first[:size]
    saved_if_dedup_bytes = size_bytes * (files.size - 1)
    {
      size_bytes: size_bytes,
      saved_if_dedup_bytes: saved_if_dedup_bytes,
      files: files.map { |file| file[:path] }
    }
  end
  {
    scanned_files: duplicates.values.flatten.size,
    groups: groups
  }
end

root_dir = '/Users/administrator/Desktop/стп' 
files_data = scan_files(root_dir)
duplicates = group_duplicates(files_data)
report = generate_report(duplicates)
File.open('/Users/administrator/Desktop/стп/duplicates.json', 'w') do |file|
  file.write(JSON.pretty_generate(report))
end
puts "Звіт про дублікати збережено в duplicates.json"

