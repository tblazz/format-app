class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format, col_index_array, first_row, empty_cols_array)
    require 'roo'
    require 'roo-xls'
    begin
      #col_index = [2, 1, 3, 4, 5, 6, 7, 8, 9, 10,	11,	12,	13,	14,	15,	16,	17,	18]
      sheet = Roo::Spreadsheet.open(create_temp_file(@file), extension: :xlsx)
    
      ##### TO IMPROVE #######
      @tmp_csv = Tempfile.new("temp_csv")#, binmode: true)
      case format
      when 1.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array)
      when 2.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array)
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
        csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row, empty_cols_array)
      when 2.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row, empty_cols_array)
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

  def csv_open(sheet, col_index_array, tmp_csv, headers, first_row, empty_cols_array)
    CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
      new_csv_row << APP_VAR["#{headers}"].map{|k,v| v.to_s.force_encoding('UTF-8')}
      (first_row..sheet.last_row).each do |row|
        csv_row = []
        # Writing inital file columns in final file selected columns
        col_index_array.each_with_index do |value, index|
          csv_row[col_index_array[index].first.to_i-1] = sheet.cell(row, index+1)
        end
        # If initial file has empty colmuns, we fill final file column with inputed value 
        empty_cols_array.each_with_index do |col, index|
          csv_row[index] = empty_cols_array[index].first if !empty_cols_array[index].first.blank? 
        end

        new_csv_row << csv_row
      end
    end
  end

end
