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

    freshstart_headers_array = [
      tél_array = ['', 'Tél', 'tel', 'tél'],
      email_array = ['', 'EMail', 'email'],
      clas_array = ['Pl.', 'Class', 'Classement'],
      prénom_array = ['', 'prénom'],
      nom_array = ['nom', 'Nom'],
      date_de_naissance_array = ['', 'DateNaissance', 'Naissance', 'datenaissance', 'naissance'],
      pays_array = ['', 'nationalité', 'pays'],
      doss_array = ['', 'Dossard', 'doss', 'Doss', 'doss.'],
      clas_cat = ['Classement par Cat.'],
      cat_array = ['Catégorie', 'Cat', 'Cat.'],
      clas_sex = ['Classement par Sexe'],
      sexe_array = ['', 'Sx', 'SEXE', 'Sexe'],
      temps_array = ['', 'Time', 'Temps'],
      moy_array = ['', 'moyenne'],
      distance_array = ['', 'Distance', 'distance', 'Dist', 'dist', 'dist.'],
      détail_course_array = [],
      message_array = [],
      nom_course_array = ['', 'course'],
      points_array = ['', 'pts', 'point']
    ]

    fftri_headers_array = [
      clé_épreuve_array = ['', 'course'],
      licence_no_array = [],
      pass_compétition_array = [],
      dossard_array = ['', 'Dossard', 'doss', 'Doss', 'doss.'],
      statut_array = [],
      nom_array = ['nom', 'Nom'],
      prénom_array = ['', 'prénom'],
      sexe_array = ['', 'Sx', 'SEXE', 'Sexe'],
      date_de_naissance_array = ['', 'DateNaissance', 'Naissance', 'datenaissance', 'naissance'],
      catégorie_dage_array = [],
      clé_club_array = [],
      clé_prestataire_array = [],
      rang_club_array = [],
      point_club_array = [],
      rang_final_array = ['Pl.', 'Class', 'Classement'],
      temps_final_array = ['', 'Time', 'Temps'],
      rang_par_sexe_array = ['Classement par Sexe'],
      rang_par_catégorie_array = ['Classement par Cat.'],
      distance_épreuve_array = ['', 'Distance', 'distance', 'Dist', 'dist', 'dist.'],
      type_discipline_épreuve_array = [],
      type_de_temps_array = [],
      temps_array = [],
      rang_temps_array = [],
      type_discipline_épreuve_array = [],
      type_de_temps_array = [],
      temps_array = [],
      rang_temps_array = [],
      type_discipline_épreuve_array = [],
      type_de_temps_array = [],
      temps_array = [],
      rang_temps_array = []
    ]

    format == "freshstart_headers" ? columns_array = freshstart_headers_array : columns_array = fftri_headers_array

    columns_array.each_with_index do |ary, index|
      ary << APP_VAR["#{format}"][index+1]
    end

    select_value = 0

    columns_array.each do |ary|
      if !ary.index(initial_file_headers[header_index]).nil?
        select_value = APP_VAR["#{format}"].select {|k, v| v == ary.last}.map{|k, v| k.to_i}
      end
    end

    return select_value

  end

end
