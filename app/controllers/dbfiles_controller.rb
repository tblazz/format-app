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
        format.html { redirect_to treatment_dbfile_path(
            @dbfile,
            format: dbfile_params[:format],
            course: dbfile_params[:distance],
            manif_key: dbfile_params[:manif_key],
            race_key: dbfile_params[:race_key]),
          notice: "Dbfile was successfully created." 
        }
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
    @course = params[:course].to_s
    @manif_key = params[:manif_key].to_s
    @race_key = params[:race_key].to_s
    @rows = FileParser.new(@dbfile).parse_file("file")
    @format == 1 ? @headers = "freshstart_headers" : @headers = "fftri_headers"
    @final_headers = @rows[1]
  end

  def process_file
    #col_index = dbfile_params[:col_indexs].values().map.with_index {|x| x.to_hash.values }
    col_index = dbfile_params[:col_indexs].to_h.map{|k,v| v}
    empty_cols = dbfile_params[:empty_cols].values().map.with_index {|x| x.to_hash.values }
    first_row = dbfile_params[:first_row].to_i
    headers_row = dbfile_params[:headers_row].to_i
    manif_key = dbfile_params[:manif_key].to_s
    race_key = dbfile_params[:race_key].to_s

    exported_file = FileGenerator.new(@dbfile).generate_file(dbfile_params[:format],
      col_index,
      first_row,
      empty_cols,
      headers_row,
      dbfile_params[:course],
      manif_key,
      race_key)
    
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
    @format = params[:format].to_i
    @rows = FileParser.new(@dbfile).parse_file("exported_file")
    @format == 1 ? @headers = "freshstart_headers" : @headers = "fftri_headers"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dbfile
      @dbfile = Dbfile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dbfile_params
      params.fetch(:dbfile, {}).permit(:file,
        :format,
        :course,
        :event_name,
        :distance,
        :sport,
        :manif_key,
        :race_key,
        :first_row,
        :headers_row,
        :manif_key,
        :race_key,
        col_indexs: {}, empty_cols: {})
    end
end
