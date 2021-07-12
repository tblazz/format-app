class DbfilesController < ApplicationController
  before_action :set_dbfile, only: %i[ show edit update destroy treatment process_file download]

  # GET /dbfiles or /dbfiles.json
  def index
    @dbfiles = Dbfile.all
  end

  # GET /dbfiles/1 or /dbfiles/1.json
  def show
  end

  # GET /dbfiles/new
  def new
    @dbfile = Dbfile.new
  end

  # GET /dbfiles/1/edit
  def edit
  end

  # POST /dbfiles or /dbfiles.json
  def create

    @dbfile = Dbfile.new(dbfile_params)
    respond_to do |format|
      if @dbfile.save
        format.html { redirect_to treatment_dbfile_path(@dbfile, format: dbfile_params[:format]), notice: "Dbfile was successfully created." }
        format.json { render :show, status: :created, location: @dbfile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dbfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dbfiles/1 or /dbfiles/1.json
  def update
    respond_to do |format|
      if @dbfile.update(dbfile_params)
        format.html { redirect_to @dbfile, notice: "Dbfile was successfully updated." }
        format.json { render :show, status: :ok, location: @dbfile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dbfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dbfiles/1 or /dbfiles/1.json
  def destroy
    @dbfile.destroy
    respond_to do |format|
      format.html { redirect_to dbfiles_url, notice: "Dbfile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def treatment
    @format = params[:format].to_i


    puts "FORMATTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
    puts params[:format].to_i.class
    puts @format
    puts "FORMATTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"


    # @binary = @dbfile.file.download
    @rows = FileParser.new(@dbfile).parse_file

    @format == 1 ? @headers = "freshstart_headers" : @headers = "fftri_headers"
    puts "HEADERSSSSSSSSSSSSSSSSSSSSSSSSSSS"
    puts @headers
    puts "HEADERSSSSSSSSSSSSSSSSSSSSSSSSSSS"
    @final_headers = APP_VAR["#{@headers}"].map{|k,v| v}
    @initial_headers = @rows[0]
    @row1 = @rows[1]
    @row2 = @rows[2]
    @row3 = @rows[3]
    @row4 = @rows[4]
  end

  def process_file

    #params[:dbfile][:col_indexs].values().map.with_index {|x| x.to_hash.values }
    col_index = dbfile_params[:col_indexs].values().map.with_index {|x| x.to_hash.values }
    empty_cols = dbfile_params[:empty_cols].values().map.with_index {|x| x.to_hash.values }
    puts "PARAMSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
    puts empty_cols[0].first.blank?
    puts "PARAMSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
    first_row = 2#dbfile_params[:first_row]

    exported_file = FileGenerator.new(@dbfile).generate_file(dbfile_params[:format], col_index, first_row, empty_cols)
    @dbfile.exported_file.attach(
      io: File.open(exported_file.path),
      filename: 'raw_data.csv',
      content_type: 'csv'
    )

    respond_to do |format| #need to add model in form to have format in client request
      if @dbfile.exported_file.attached?
        format.html { redirect_to download_dbfile_path(@dbfile), notice: "Votre fichier a été traité" }
        format.json { render :show, status: :created, location: @dbfile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dbfile.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dbfile
      @dbfile = Dbfile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dbfile_params
      params.fetch(:dbfile, {}).permit(:file, :format, :event_name, :distance, :sport, :manif_key, :race_key, col_indexs: {}, empty_cols: {})
    end
end
