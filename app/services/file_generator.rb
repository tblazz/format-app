class FileGenerator
  def initialize(file)
    @file = file
  end

  def generate_file(format)
    require 'roo'
    require 'roo-xls'
    begin
      sheet = Roo::Spreadsheet.open(create_temp_file(@file), extension: :xlsx)
      #sheet.parse(headers: true)
      headers = sheet.row(1)
      row1 = sheet.row(2)
      row2 = sheet.row(3)
      row3 = sheet.row(4)
      row4 = sheet.row(5)
      column_number = headers.size

      case format
      when 1.to_s
        csv = CSV.generate(headers: true) do |csv|
          csv << APP_VAR["freshstart_headers"]
        end
      when 2.to_s
        csv = CSV.generate(headers: true) do |csv|
          csv << APP_VAR["fftri_headers"]
        end
      end

      exported_file = csv
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

end