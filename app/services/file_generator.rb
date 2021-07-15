class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format, col_index_array, first_row, empty_cols_array, headers_row)
    require 'roo'
    require 'roo-xls'
    begin
      #col_index = [2, 1, 3, 4, 5, 6, 7, 8, 9, 10,	11,	12,	13,	14,	15,	16,	17,	18]
      sheet = Roo::Spreadsheet.open(create_temp_file(@file), extension: :xlsx)
      class_cat_array = class_cat_calculate(sheet, headers_row, first_row)

      puts 'catcollllllllllllllllllllllllllllllll'
      puts class_cat_array
      puts 'catcollllllllllllllllllllllllllllllll'
    
      ##### TO IMPROVE #######
      @tmp_csv = Tempfile.new("temp_csv")#, binmode: true)
      case format
      when 1.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array, headers_row)
      when 2.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array, headers_row)
      end

      exported_file = @tmp_csv
      return exported_file
      ##### TO IMPROVE #######
    
    rescue Zip::Error

      ##### TO IMPROVE #######
      sheet = Roo::Spreadsheet.open(create_temp_file(@file))
      @tmp_csv = Tempfile.new("temp_csv")#, binmode: true)

      case format
      when 1.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array, headers_row)
      when 2.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array, headers_row)
      end

      exported_file = @tmp_csv
      return exported_file
      ##### TO IMPROVE #######

    end
  end

  def create_temp_file(model)
    filename = model.file.blob.filename
    @tmp = Tempfile.new([filename.base, filename.extension_with_delimiter], binmode: true)
    @tmp.write(model.file.download)
    @tmp.rewind
    @tmp
  end

  def csv_open(sheet, col_index_array, tmp_csv, headers, first_row, empty_cols_array, headers_row)
    CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
      csv_headers = APP_VAR["#{headers}"].map{|k,v| v.to_s.force_encoding('UTF-8')}
      new_csv_row << csv_headers
      (first_row..sheet.last_row).each do |row|
        csv_row = []
        # Writing inital file columns in final file selected columns
        col_index_array.each_with_index do |value, index|
          csv_row[col_index_array[index].first.to_i-1] = sheet.cell(row, index+1) #|| reformat(sheet.cell(row, index+1))
        end


        format_csv_row(csv_row, csv_headers)

        
        # If initial file has empty colmuns, we fill final file column with inputed value 
        empty_cols_array.each_with_index do |col, index|
          csv_row[index] = empty_cols_array[index].first if !empty_cols_array[index].first.blank? 
        end

        #class_cat_array.each do |cat_class|
        #  csv_row << cat_class
        #end
        
        new_csv_row << csv_row
      end
    end
  end






  def format_csv_row(row, headers)


    headers.each_with_index do |cell, index|
      if !row[index].blank?
        case cell
        when "Doss." || "Dossard" #|| cell == "Dos." || cell == "Dossard" || cell =="Dos"
          row[index] = row[index].delete('^0-9')
        when "Tél" #|| cell == "Téléphone" || cell == "tel" || cell == "tél"
          row[index] = row[index].gsub('0', '33').gsub(' ', '') if row[index][0] == '0'
        when "Clas." #|| cell == "tel" || cell == "tél" || "Tél"
          row[index] = row[index].to_s.gsub('.', '')
        when "Cat"
          row[index] = row[index].gsub('M', 'V')
          row[index] = row[index][0,row[index].length-1] if row[index].end_with?('F') || row[index].end_with?('M') || row[index].end_with?('H')
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


  end

  def class_cat_calculate(sheet, headers_row, first_row)
    
    class_array = []
    class_cat_array = []
    cat_col_index = sheet.row(headers_row).index('Catégorie')
    cat_col = sheet.column(cat_col_index + 1)


    cat_col[first_row..cat_col.length].each do |row| 
      class_array << row
      class_cat_array << class_array.count(row)
    end

    return class_cat_array

  end




end
