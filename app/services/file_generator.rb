class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format, col_index_array, first_row, empty_cols_array, headers_row, course)
    require 'roo'
    require 'roo-xls'

    begin
      sheet = Roo::Spreadsheet.open(create_temp_file(@file), extension: :xlsx)
    rescue Zip::Error
      sheet = Roo::Spreadsheet.open(create_temp_file(@file))
    end

    class_cat_array = class_cat_calculate(sheet, headers_row, first_row)
    class_sex_array = class_sex_calculate(sheet, headers_row, first_row)

    @tmp_csv = Tempfile.new("temp_csv")#, binmode: true)
    case format
    when 1.to_s
      csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array, course)
    when 2.to_s
      csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array, course)
    end

    exported_file = @tmp_csv
    return exported_file
  end



  def create_temp_file(model)
    filename = model.file.blob.filename
    @tmp = Tempfile.new([filename.base, filename.extension_with_delimiter], binmode: true)
    @tmp.write(model.file.download)
    @tmp.rewind
    @tmp
  end



  def csv_open(sheet, col_index_array, tmp_csv, headers, first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array, course)
    CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
      csv_headers = APP_VAR["#{headers}"].map{|k,v| v.to_s.force_encoding('UTF-8')}
      new_csv_row << csv_headers
      (first_row..sheet.last_row).each_with_index do |row, row_index|

        csv_row = []

        average_speed_calculate(sheet, csv_row, headers_row, row, headers)

        # Writing inital file columns in final file selected columns
        col_index_array.each_with_index do |value, col_index|
          csv_row[value.to_i-1] = sheet.cell(row, col_index+1) if csv_row[value.to_i-1].blank? #to avoid rewrite bug
        end

        #remove useless char, formating datas in csv row
        format_csv_row(csv_row, csv_headers)

        #add category rank if "Clt Cat" is not in header sheet
        class_cat_present = false
        ["Clt Cat", "Classement par Cat."].each do |str|
          class_cat_present = sheet.row(headers_row).include?(str)
          break if class_cat_present
        end
        add_class_cat(csv_row, class_cat_array, row_index, headers) unless class_cat_present

        #add sex rank
        class_sex_present = false
        ["Classement par Sexe", "Clt Sex"].each do |str|
          class_sex_present = sheet.row(headers_row).include?(str)
          break if class_sex_present
        end
        add_class_sex(csv_row, class_sex_array, row_index, headers) unless class_sex_present

        #add course if field is written in initial view
        add_course(csv_row, course) if headers == "freshstart_headers" && !course.blank?

        #If initial file has empty colmuns, we fill final file column with inputed value 
        empty_cols_array.each_with_index do |col, index|
          csv_row[index] = empty_cols_array[index].first if !empty_cols_array[index].first.blank? 
        end

        new_csv_row << csv_row
      end
    end
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



  def class_cat_calculate(sheet, headers_row, first_row)
    class_array = []
    class_cat_array = []
    cat_col_index = nil
    ["Catégorie", "Cat"].each do |str|
      index = sheet.row(headers_row).index(str)
      cat_col_index = index if !index.nil?
      break if !index.nil?
    end

    return if cat_col_index.nil?
    cat_col = sheet.column(cat_col_index + 1)

    cat_col[first_row-1..cat_col.length-1].each do |row| 
      class_array << row
      class_cat_array << class_array.count(row)
    end

    return class_cat_array
  end



  def class_sex_calculate(sheet, headers_row, first_row)
    class_array = []
    class_sex_array = []
    sex_col_index = nil

    ['Sx', 'SEXE', 'Sexe'].each do |str|
      index = sheet.row(headers_row).index(str)
      sex_col_index = index if !index.nil?
      break if !index.nil?
    end

    return if sex_col_index.nil?
    sex_col = sheet.column(sex_col_index + 1)

    sex_col[first_row-1..sex_col.length-1].each do |row| 
      class_array << row
      class_sex_array << class_array.count(row)
    end

    return class_sex_array
  end



  def add_class_cat(csv_row, class_cat_array, row_index, headers)
    csv_row[8] = class_cat_array[row_index] if !class_cat_array.nil? && headers == "freshstart_headers" #if clas cat non présent
    csv_row[17] = class_cat_array[row_index] if !class_cat_array.nil? && headers == "fftri_headers" #if clas cat non présent
  end



  def add_class_sex(csv_row, class_sex_array, row_index, headers)
    csv_row[10] = class_sex_array[row_index] if !class_sex_array.nil? && headers == "freshstart_headers" #if clas cat non présent
    csv_row[16] = class_sex_array[row_index] if !class_sex_array.nil? && headers == "fftri_headers" #if clas cat non présent
  end



  def add_course(csv_row, course)
    csv_row[14] = course
    csv_row[15] = course
    csv_row[17] = course
  end



  def average_speed_calculate(sheet, csv_row, headers_row, xl_row, headers)#, time_design_array, speed_design_array)
    distance_col_index = nil
    time_col_index = nil

    ['Distance', 'Dist'].each do |str|
      index = sheet.row(headers_row).index(str)
      distance_col_index = index if !index.nil?
      break if !index.nil?
    end

    ['Temps', 'Time'].each do |str|
      index = sheet.row(headers_row).index(str)
      time_col_index = index if !index.nil?
      break if !index.nil?
    end

    if distance_col_index.nil? || time_col_index.nil?
      return csv_row[13] = 'Average not processable'
    elsif  sheet.cell(xl_row, distance_col_index + 1).nil? ||sheet.cell(xl_row, distance_col_index + 1).blank?
      return csv_row[13] = 'Average not processable'
    elsif  sheet.cell(xl_row, time_col_index + 1).nil? ||sheet.cell(xl_row, time_col_index + 1).blank?
      return csv_row[13] = 'Average not processable'
    end

    distance = convert_dist(sheet.cell(xl_row, distance_col_index + 1))
    time = convert_time(sheet.cell(xl_row, time_col_index + 1))

    hours = time[0..1]
    minutes = time[3..4]
    seconds = time[6, time.length]
    hour_time = (hours.to_i * 3600 + minutes.to_i * 60 + seconds.to_f) / 3600
    average_speed = (distance / hour_time).round(2)

    return csv_row[13] = average_speed if headers == "freshstart_headers" and !distance_col_index.nil? && !time_col_index.nil?
  end


  
  def convert_time(time)
    time = '0' + time if time[1] == 'h' || time[1] == ':'
    time = '00:' + time if time[2] == ":" && time.length == 5
    time = time.gsub(',00', '').gsub('sec', '').gsub('h', ':').gsub('m', ':')
    return time
  end



  def convert_dist(dist)
    dist = dist.to_s.gsub('km', '')
    dist.to_i > 500 ? dist = dist.to_i / 1000 : dist = dist.to_i
    return dist
  end


end
