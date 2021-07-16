class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format, col_index_array, first_row, empty_cols_array, headers_row)
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
      csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array)
    when 2.to_s
      csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array)
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

  def csv_open(sheet, col_index_array, tmp_csv, headers, first_row, empty_cols_array, headers_row, class_cat_array, class_sex_array)
    CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
      csv_headers = APP_VAR["#{headers}"].map{|k,v| v.to_s.force_encoding('UTF-8')}
      new_csv_row << csv_headers
      (first_row..sheet.last_row).each_with_index do |row, row_index|

        csv_row = []

        average_speed_calculate(sheet, csv_row, headers_row, row, headers)
        # Writing inital file columns in final file selected columns
        col_index_array.each_with_index do |value, col_index|
          csv_row[col_index_array[col_index].first.to_i-1] = sheet.cell(row, col_index+1)
        end

        #remove useless char, formating datas in csv row
        format_csv_row(csv_row, csv_headers)
        #add category rank if "Clt Cat" is not in header sheet
        add_class_cat(csv_row, class_cat_array, row_index, headers) if !sheet.row(headers_row).include?("Clt Cat")
        #add sex rank
        add_class_sex(csv_row, class_sex_array, row_index, headers)


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
      return if row[index].blank?
      case cell
      when "Doss." || "Dossard"
        row[index] = row[index].delete('^0-9')
      when "Tél"
        row[index] = row[index].gsub('0', '33').gsub(' ', '') if row[index][0] == '0'
      when "Clas."
        row[index] = row[index].to_s.gsub('.', '')
      when "Cat"
        row[index] = row[index].gsub('M', 'V') #if row[index].is_a? String
        row[index] = row[index][0,row[index].length-1] if (row[index].end_with?('F') || row[index].end_with?('M') || row[index].end_with?('H')) #&& row[index].is_a? String
      when "Sexe"
        row[index] = row[index].gsub('Femme', 'F').gsub('Homme', 'H')
      when "Temps"
        row[index] = '0' + row[index] if row[index][1] == 'h' || row[index][1] == ':'
        row[index] = '00:' + row[index] if row[index][2] == ":" && row[index].length == 5
        row[index] = row[index].gsub(',00', '').gsub('sec', '').gsub('h', ':').gsub('m', ':')
      when "Distance" || "Distance épreuve"
        row[index] = row[index].to_s.gsub('km', '')
        row[index] = row[index].to_i / 1000 if row[index].to_i > 500
      end
    end
  end


  def class_cat_calculate(sheet, headers_row, first_row)
    class_array = []
    class_cat_array = []
    cat_col_index = sheet.row(headers_row).index('Catégorie')
    # ["Catégorie"].each do |str|
    #   index = sheet.row(headers_row).index(str)
    #   cat_col_index = index if !index.nil?
    # end

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
    sex_col_index = sheet.row(headers_row).index('Sx') || sex_col_index = sheet.row(headers_row).index('SEXE')

    ['Sx', 'SEXE'].each do |str|
      index = sheet.row(headers_row).index(str)
      sex_col_index = index if !index.nil?
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
    csv_row[3] = class_cat_array[row_index] if !class_cat_array.nil? && headers == "freshstart_headers" #if clas cat non présent
    csv_row[15] = class_cat_array[row_index] if !class_cat_array.nil? && headers == "fftri_headers" #if clas cat non présent
  end

  def add_class_sex(csv_row, class_sex_array, row_index, headers)
    csv_row[2] = class_sex_array[row_index] if !class_sex_array.nil? && headers == "freshstart_headers" #if clas cat non présent
    csv_row[16] = class_sex_array[row_index] if !class_sex_array.nil? && headers == "fftri_headers" #if clas cat non présent
  end

  def average_speed_calculate(sheet, csv_row, headers_row, xl_row, headers)
    distance_col_index = 9999
    time_col_index = 9999
    ['Distance', 'Dist'].each do |str|
      index = sheet.row(headers_row).index(str)
      distance_col_index = index if !index.nil?
    end

    ['Temps', 'Time'].each do |str|
      index = sheet.row(headers_row).index(str)
      time_col_index = index if !index.nil?
    end

    puts "INDEXSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
    puts time_col_index
    puts distance_col_index
    puts sheet.cell(xl_row, distance_col_index+1)
    puts sheet.cell(xl_row, time_col_index+1)
    time = sheet.cell(xl_row, time_col_index+1)

    time = '0' + time if time[1] == 'h' || time[1] == ':'
    time = '00:' + time if time[2] == ":" && time.length == 5
    time = time.gsub(',00', '').gsub('sec', '').gsub('h', ':').gsub('m', ':')

    puts time



    puts "INDEXSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"

    return csv_row[10] = 'Average not processable' if distance_col_index.nil? || time_col_index.nil?

    csv_row[10] = sheet.cell(xl_row, distance_col_index + 1) / sheet.cell(xl_row, time_col_index + 1) if headers == "freshstart_headers"


    
  end

end
