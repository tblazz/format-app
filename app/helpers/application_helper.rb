module ApplicationHelper

  def is_column_empty?(file, column, first_row)
    require 'roo'
    require 'roo-xls'
    begin
      sheet = Roo::Spreadsheet.open(create_temp_file(file), extension: :xlsx)
      headers = sheet.row(1)
      column_number = headers.size
      empty = true
    
      (first_row..sheet.last_row).each do |row|
          empty = false if !sheet.cell(row, column+1).nil?
      end
      return empty

    rescue Zip::Error
      sheet = Roo::Spreadsheet.open(create_temp_file(file))
      headers = sheet.row(1)
      column_number = headers.size
      empty = true
    
      (first_row..sheet.last_row).each do |row|
          empty = false if !sheet.cell(row, column+1).nil?
      end
      return empty
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
