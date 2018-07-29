class RelationtblsController < ApplicationController
  before_action :set_relationtbl, only: [:show, :edit, :update, :destroy]

  # GET /relationtbls
  # GET /relationtbls.json
  def index
    @relationtbls = Relationtbl.all
  end

  # GET /relationtbls/1
  # GET /relationtbls/1.json
  def show
  end

  # GET /relationtbls/new
  def new
    @relationtbl = Relationtbl.new
  end

  # GET /relationtbls/1/edit
  def edit
  end

  # POST /relationtbls
  # POST /relationtbls.json
  def create
    @relationtbl = Relationtbl.new(relationtbl_params)

    respond_to do |format|
      if @relationtbl.save
        format.html { redirect_to @relationtbl, notice: 'Relationtbl was successfully created.' }
        format.json { render :show, status: :created, location: @relationtbl }
      else
        format.html { render :new }
        format.json { render json: @relationtbl.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relationtbls/1
  # PATCH/PUT /relationtbls/1.json
  def update
    respond_to do |format|
      if @relationtbl.update(relationtbl_params)
        format.html { redirect_to @relationtbl, notice: 'Relationtbl was successfully updated.' }
        format.json { render :show, status: :ok, location: @relationtbl }
      else
        format.html { render :edit }
        format.json { render json: @relationtbl.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationtbls/1
  # DELETE /relationtbls/1.json
  def destroy
    @relationtbl.destroy
    respond_to do |format|
      format.html { redirect_to relationtbls_url, notice: 'Relationtbl was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relationtbl
      @relationtbl = Relationtbl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationtbl_params
      params.require(:relationtbl).permit(:relationid, :frommvid, :tomvid, :fromtitle, :totitle, :updatedate)
    end
end
