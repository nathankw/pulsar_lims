class TreatmentsController < ApplicationController
  before_action :set_treatment, only: [:show, :edit, :update, :destroy]

  def select_options                                                                                   
    #Called via ajax.                                        
    #Typically called when the user selects the refresh icon in any form that has a treatments selection.
    @records = Treatment.all
    render "application_partials/select_options", layout: false
  end 

  def index
    super
  end

  def show
    authorize @treatment
  end

  def new
    authorize Treatment
    @treatment = Treatment.new
  end

  def edit
    authorize @treatment
  end

  def create
    authorize Treatment
    @treatment = Treatment.new(treatment_params)
    @treatment.user = current_user

    respond_to do |format|
      if @treatment.save
        format.html { redirect_to @treatment, notice: 'Treatment was successfully created.' }
        format.json { render json: @treatment, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @treatment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @treatment
    respond_to do |format|
      if @treatment.update(treatment_params)
        format.html { redirect_to @treatment, notice: 'Treatment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @treatment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ddestroy(@treatment, redirect_path_success: treatments_path)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_treatment
      @treatment = Treatment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def treatment_params
      params.require(:treatment).permit(
        :concentration, 
        :concentration_unit_id, 
        :description, 
        :duration, 
        :duration_units, 
        :name, 
        :notes,
        :temperature_celsius, 
        :treatment_term_name_id, 
        :treatment_type, 
        :upstream_identifier, 
        :document_ids => [], 
        :treatment_ids => []
      )
    end
end
