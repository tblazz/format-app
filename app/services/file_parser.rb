class FileParser
  def initialize(file)
    @file = file
  end

  def parse_file(wich_file)


    require 'roo'
    require 'roo-xls'
    begin
      sheet = Roo::Spreadsheet.open(create_temp_file(@file, wich_file), extension: :xlsx)
      ##### TO IMPROVE #######
      headers = sheet.row(1)
      row1 = sheet.row(2)
      row2 = sheet.row(3)
      row3 = sheet.row(4)
      row4 = sheet.row(5)
      column_number = headers.size
      return headers, row1, row2, row3, row4
      ##### TO IMPROVE #######

    rescue Zip::Error
      sheet = Roo::Spreadsheet.open(create_temp_file(@file, wich_file))
      ##### TO IMPROVE #######
      headers = sheet.row(1)
      row1 = sheet.row(2)
      row2 = sheet.row(3)
      row3 = sheet.row(4)
      row4 = sheet.row(5)
      column_number = headers.size
      return headers, row1, row2, row3, row4
      ##### TO IMPROVE ####### 
    end
  end

  def create_temp_file(model, wich_file)
    wich_file == "file" ? filename = model.file.blob.filename : filename = model.exported_file.blob.filename 
    @tmp = Tempfile.new([filename.base, filename.extension_with_delimiter], binmode: true)
    wich_file == "file" ? @tmp.write(model.file.download) : @tmp.write(model.exported_file.download)
    @tmp.rewind
    @tmp
  end

end
