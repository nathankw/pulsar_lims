class AntibodiesController < ApplicationController
	include AntibodyPurificationsConcern #provides add_antibody_purifications()
  before_action :set_antibody, only: [:show, :edit, :update, :destroy]

  # GET /antibodies
  # GET /antibodies.json
  def index
    @antibodies = policy_scope(Antibody).order("lower(name)")
  end

  # GET /antibodies/1
  # GET /antibodies/1.json
  def show
		authorize @antibody
  end

  # GET /antibodies/new
  def new
		authorize Antibody
    @antibody = Antibody.new
  end

  # GET /antibodies/1/edit
  def edit
		authorize @antibody
  end

  # POST /antibodies
  # POST /antibodies.json
  def create
    @antibody = Antibody.new(antibody_params)
		authorize @antibody
		@antibody.user = current_user
		@antibody = add_antibody_purifications(@antibody,params[:antibody][:antibody_purification_ids])
		#@antibody.add_antibody_purifications(params[:antibody][:antibody_purifications])
		
    respond_to do |format|
      if @antibody.save
        format.html { redirect_to @antibody, notice: 'Antibody was successfully created.' }
        format.json { render action: 'show', status: :created, location: @antibody }
      else
        format.html { render action: 'new' }
        format.json { render json: @antibody.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /antibodies/1
  # PATCH/PUT /antibodies/1.json
  def update
		authorize @antibody
		@antibody = add_antibody_purifications(@antibody,params[:antibody][:antibody_purification_ids])
		#@antibody.remove_antibody_purifications(params[:remove_antibody_purifications])
		#@antibody.add_antibody_purifications(params[:antibody][:antibody_purifications])
    respond_to do |format|
      if @antibody.update(antibody_params)
        format.html { redirect_to @antibody, notice: 'Antibody was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @antibody.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /antibodies/1
  # DELETE /antibodies/1.json
  def destroy
		authorize @antibody
    @antibody.destroy
    respond_to do |format|
      format.html { redirect_to antibodies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_antibody
      @antibody = Antibody.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def antibody_params
      params.require(:antibody).permit(:organism_id, :vendor_id, :isotype_id, :target_id, :vendor_product_identifier, :vendor_product_url, :lot_identifier, :clonality, :antigen_description, :antigen_sequence, :name, antibody_purifications_attributes: [:id,:_destroy])
    end

end
