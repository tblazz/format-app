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
      new_sheet = format_sheet_column(sheet, headers_row)
    
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

        # If initial file has empty colmuns, we fill final file column with inputed value 
        empty_cols_array.each_with_index do |col, index|
          csv_row[index] = empty_cols_array[index].first if !empty_cols_array[index].first.blank? 
        end

        format_csv_row(csv_row, csv_headers)

        new_csv_row << csv_row
      end
    end
  end




  # def reformat_sheet(sheet, headers_row)
  #   sheet.row(headers_row).each_with_index do |cel, index|
  #     reformat_doss(sheet, index) if cel == "Doss." || cel == "Dos." || cel == "Dossard" || cel =="Dos"

  #   end
  # end

  # def reformat_doss(row)
  #   sheet.column(index + 1).drop(1).each_with_index do |cel, row_index|
  #     puts cel
  #     puts cel.class 
  #     puts cel.delete('^0-9')
  #     puts index
  #     #sheet.cell(2,2) = "cel.delete('^0-9')" 
  #   end
  # end



  def format_csv_row(row, headers)
    puts "NONN FORMATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
    puts row
    puts "NONN FORMATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"

    headers.each_with_index do |cell, index|
      puts "CELLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"

      puts cell == "Cat"
      puts cell == "Tél"
      puts cell == "Clas."
      puts cell == "Cat"

      puts "CELLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"

      if !row[index].blank?
        if cell == "Doss." #|| cell == "Dos." || cell == "Dossard" || cell =="Dos"
          row[index] = row[index].delete('^0-9')
        elsif cell = "Tél" #|| cell == "Téléphone" || cell == "tel" || cell == "tél"
          row[index] = row[index].gsub('0', '33').gsub(' ', '') if row[index][0] == '0'
        elsif cell == "Clas." #|| cell == "tel" || cell == "tél" || "Tél"
          row[index] = row[index].delete('^0-9')

        elsif cell == "Cat"
          puts "CATEGORYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
          row[index] = row[index].gsub('M', 'V')
          row[index] = row[index][0,row[index].length-1] if row[index].end_with?('F') || row[index].end_with?('M') || row[index].end_with?('H')

        end
      end
    end




    puts "FORMATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
    puts row
    puts "FORMATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
  end

  def format_sheet_column(initial_col_index, final_col_index)
    
  end




end
