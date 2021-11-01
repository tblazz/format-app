class FileParser
  def initialize(file)
    @file = file
  end

  def parse_file(wich_file)
    require 'roo'
    require 'roo-xls'

    begin
      sheet = Roo::Spreadsheet.open(create_temp_file(@file, wich_file), extension: :xlsx)
    rescue Zip::Error
      sheet = Roo::Spreadsheet.open(create_temp_file(@file, wich_file))
    end

      headers = sheet.row(1)
      row1 = sheet.row(2)
      row2 = sheet.row(3)
      row3 = sheet.row(4)
      row4 = sheet.row(5)
      row5 = sheet.row(6)
      format_csv_row(row1, headers)
      format_csv_row(row2, headers)
      format_csv_row(row3, headers)
      format_csv_row(row4, headers)
      format_csv_row(row5, headers)
      column_number = headers.size

      return headers, row1, row2, row3, row4, row5

  end

  def create_temp_file(model, wich_file)
    wich_file == "file" ? filename = model.file.blob.filename : filename = model.exported_file.blob.filename 
    @tmp = Tempfile.new([filename.base, filename.extension_with_delimiter], binmode: true)
    wich_file == "file" ? @tmp.write(model.file.download) : @tmp.write(model.exported_file.download)
    @tmp.rewind
    @tmp
  end

  def format_csv_row(row, headers)
    headers.each_with_index do |cell, index|
      next if row[index].blank?
      case cell
      when "Doss." || "Dossard"
        row[index] = row[index].to_s.delete('^0-9')
      when "Tél"
        row[index] = row[index].gsub('0', '33').gsub(' ', '') if row[index][0] == '0'
      when "Clas."
        row[index] = row[index].to_s.gsub('.', '')
      when "Cat"
        if row[index].is_a? String
          row[index] = row[index].gsub('M', 'V')
          row[index] = row[index][0,row[index].length-1] if (row[index].end_with?('F') || row[index].end_with?('M') || row[index].end_with?('H'))
        end
      when "Sexe"
        row[index] = row[index].gsub('Femme', 'F').gsub('Homme', 'H')
      when "Temps"
        row[index] = convert_time(row[index])
      when "Distance" || "Distance épreuve"
        row[index] = row[index].to_s.gsub('km', '')
        row[index] = row[index].to_i / 1000 if row[index].to_i > 500
      end
    end
  end


  def convert_time(time)
    return seconds_to_hms(time) if time.class == Integer

    time = '0' + time if time[1] == 'h' || time[1] == ':'
    time = '00:' + time if time[2] == ":" && time.length == 5
    time = time.gsub(',00', '').gsub('sec', '').gsub('h', ':').gsub('m', ':')
    return time
  end

  def seconds_to_hms(sec)
    "%02d:%02d:%02d" % [sec / 3600, sec / 60 % 60, sec % 60]
  end

end
