class FileGenerator
  def initialize(file)
    @file = file
  end

  def parse_file


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
      puts "TABLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
      column_number = headers.size
      puts "TABLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
      return headers, row1, row2, row3, row4 

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