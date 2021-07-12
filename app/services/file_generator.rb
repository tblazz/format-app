class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format, col_index_array, first_row, empty_cols_array)
    require 'roo'
    require 'roo-xls'
    begin
      #col_index = [2, 1, 3, 4, 5, 6, 7, 8, 9, 10,	11,	12,	13,	14,	15,	16,	17,	18]
      puts "COL_INDEXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      puts empty_cols_array
      puts "COL_INDEXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

      sheet = Roo::Spreadsheet.open(create_temp_file(@file), extension: :xlsx)
      @tmp_csv = Tempfile.new("temp_csv")#, binmode: true)

      case format
      when 1.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "freshstart_headers", first_row)
      when 2.to_s
        csv_open(sheet, col_index_array, @tmp_csv, "fftri_headers", first_row)
      end

      exported_file = @tmp_csv
      return exported_file

    rescue Zip::Error
      sheet = Roo::Spreadsheet.open(create_temp_file(@file))
      # puts sheet.row(1)
      # puts sheet.column(2)
    end
  end

  def create_temp_file(model)
    filename = model.file.blob.filename
    @tmp = Tempfile.new([filename.base, filename.extension_with_delimiter], binmode: true)
    @tmp.write(model.file.download)
    @tmp.rewind
    @tmp
  end

  def csv_open(sheet, col_index_array, tmp_csv, headers, first_row)
    CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
      new_csv_row << APP_VAR["#{headers}"].map{|k,v| v.to_s.force_encoding('UTF-8')}
      (first_row..sheet.last_row).each do |row|
        csv_row = []
        col_index_array.each_with_index do |value, index|
          csv_row[col_index_array[index].first.to_i-1] = sheet.cell(row, index+1)
        end

        # empty_cols_array.each do |col|
        #   csv_row .... = empty_cols_array[col].value
        # end


        new_csv_row << csv_row
      end
    end
  end

  # def write_empty_cols(empty_cols_array, tmp_csv)
  #   CSV.open(tmp_csv.path, "a+", col_sep: ";", headers: true) do |new_csv_row|
     
  #       if col.blank?
  #         csv_row[col] = empty_cols_array
  #       end
  #     end
  #   end
  # end

end