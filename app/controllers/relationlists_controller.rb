class RelationlistsController < ApplicationController
  #before_action :set_relationlist, only: [:show, :edit, :update, :destroy]
  before_action :set_relationlist
  PER = 30 
  # GET /relationlists
  # GET /relationlists.json
  def index
    @relationlists = Relationlist.all.order("updated_at DESC").limit(10)
    @smvlists = Smvlist.all
  end
  def nomoza

    #@smvlists = Smvlist.where("smvtitle like '%無%'").or(Smvlist.where("tags like '%無%'"))
    @smvlists = Smvlist.where("tags like ? or smvtitle like ?",  '%無%','%無%').order("updated_at DESC").page(params[:page]).per(PER)
  
  end
  
  
  def find
	@msg = 'please type search word...'
	@smvlist = Array.new
	if request.post? then
		@smvlist = Smvlist.where("smvtitle like '%" +  params[:find] + "%'")
		@relationlists = Relationlist.all.order("updated_at DESC")
	else
	  @relationlists = Relationlist.all.order("updated_at DESC")
	end
  end
  
  # GET /relationlists/1
  # GET /relationlists/1.json
  def show
  end

  # GET /relationlists/new
  def new
    @relationlist = Relationlist.new
  end

  # GET /relationlists/1/edit
  def edit
  end

  # POST /relationlists
  # POST /relationlists.json
  def create
    @relationlist = Relationlist.new(relationlist_params)

    respond_to do |format|
      if @relationlist.save
        format.html { redirect_to @relationlist, notice: 'Relationlist was successfully created.' }
        format.json { render :show, status: :created, location: @relationlist }
      else
        format.html { render :new }
        format.json { render json: @relationlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relationlists/1
  # PATCH/PUT /relationlists/1.json
  def update
    respond_to do |format|
      if @relationlist.update(relationlist_params)
        format.html { redirect_to @relationlist, notice: 'Relationlist was successfully updated.' }
        format.json { render :show, status: :ok, location: @relationlist }
      else
        format.html { render :edit }
        format.json { render json: @relationlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationlists/1
  # DELETE /relationlists/1.json
  def destroy
    @relationlist.destroy
    respond_to do |format|
      format.html { redirect_to relationlists_url, notice: 'Relationlist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relationlist
      #@relationlist = Relationlist.find(params[:id])
      @relationlist = Relationlist.all.limit(10)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def relationlist_params
      params.require(:relationlist).permit(:relationid, :frommvid, :tomvid, :fromtitle, :totitle, :updatedate)
    end
end