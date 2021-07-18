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


  def select_headers(initial_file_headers, header_index, format, col_in_final_header)

    # puts "MAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    # puts APP_VAR["#{format}"].map {|k, v| k if v == 'Moy'}
    # puts "MAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"


columns_array = [
  cat_array = ['Catégorie', 'Cat', 'Cat.'],
  clas_array = ['Pl.', 'Class', 'Classement'],
  clas_sex = [],
  clas_cat = [], 
  détail_course_array = [],
  datede_naissance_array = ['', 'DateNaissance', 'Naissance', 'datenaissance', 'naissance'],
  distance_array = ['', 'Distance', 'distance', 'Dist', 'dist', 'dist.'],
  doss_array = ['', 'Dossard', 'doss', 'Doss', 'doss.'],
  email_array = ['', 'EMail', 'email'],
  message_array = [],
  moy_array = ['', 'moyenne'],
  nom_array = [],
  nom_course_array = ['', 'course'],
  pays_array = ['', 'nationalité', 'pays'],
  points_array = ['', 'pts', 'point'],
  prénom_array = ['', 'prénom'],
  sexe_array = ['', 'Sx', 'SEXE'],
  tél_array = ['', 'Tél', 'tel', 'tél'],
  temps_array = ['', 'Time', 'Temps']
  ]


  columns_array.each_with_index do |ary, index|
    ary << APP_VAR["#{format}"][index+1]
  end

  select_value = 0

  columns_array.each do |ary|
    if !ary.index(initial_file_headers[header_index]).nil?
      puts ary.last
      select_value = APP_VAR["#{format}"].select {|k, v| v == ary.last}.map{|k, v| k.to_i}
    end
  end

  return select_value




  end

end
