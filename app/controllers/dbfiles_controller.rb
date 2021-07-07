class DbfilesController < ApplicationController
  before_action :set_dbfile, only: %i[ show edit update destroy treatment ]

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
        format.html { redirect_to treatment_dbfile_path(@dbfile), notice: "Dbfile was successfully created." }
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
    # @binary = @dbfile.file.download
    @file = @dbfile
    @rows = FileParser.new(@file).parse_file
    puts "AFTER DLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
    @headers = @rows[0]
    @row1 = @rows[1]
    @row2 = @rows[2]
    @row3 = @rows[3]
    @row4 = @rows[4]

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dbfile
      @dbfile = Dbfile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dbfile_params
      params.fetch(:dbfile, {}).permit(:file)
    end
end
