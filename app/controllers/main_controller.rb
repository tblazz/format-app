class MainController < ApplicationController

  def new_file
  end

  def upload
    @temp_file = params[:file].file

    @temp_file.open
    @temp_file.read
    @temp_path = @temp_file.path

    puts "PATHSSSSSSSSSSSSSSSSSSSSSSS"
    puts @temp_path
    puts "PATHSSSSSSSSSSSSSSSSSSSSSSS"

    #redirect_to :edit
  end

  def edit
    puts "EDITTTTTTTTTTTTTTTTTTTTTTTTTTT"
    puts @temp_path
    puts "EDITTTTTTTTTTTTTTTTTTTTTTTTTTT"
  end

  def download
  end
end
