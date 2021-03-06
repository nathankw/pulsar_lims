class CrisprModificationsController < ApplicationController
  before_action :set_crispr_modification, only: [:show, :edit, :update, :destroy, :prototype_instances]
  skip_after_action :verify_authorized, only: [:select_chromosome_on_reference_genome, :select_crispr_construct, :prototype_instances]

  def select_options
    #Called via ajax.
    #Typically called when the user selects the refresh icon in any form that has a crispr_modifications selection.
    @records = CrisprModification.all
    render "application_partials/select_options", layout: false
  end

  def prototype_instances
    #Called via ajax
    set_model_class()
    @records = policy_scope(CrisprModification.where({from_prototype: @crispr})).page params[:page]
    @no_new_btn = true
    @title = "Prototype instances of CRISPR Modification #{@crispr.name}"
    render action: "index"
  end

  def select_crispr_construct
    # Called remotely in the crispr form when the user clicks the "Add Crispr Construct" button.
    # The rendered view is added to the HTML by Javascript.
    #
    # Expected params:
    #   1. exclude_ids - Array of CrisprConstruct IDs to exclude from the selection.
    exclude_ids = params[:exclude_ids]
    @crispr = CrisprModification.new
    @crispr_constructs = CrisprConstruct.where.not(id: exclude_ids)
    render layout: false
  end

  def select_chromosome_on_reference_genome
    @crispr = CrisprModification.new
    @crispr.build_genomic_integration_site
    @chromosomes = Chromosome.where(reference_genome_id: params["reference_genome_id"])
    render layout: false
  end

  def index
    super
  end

  def show
    authorize @crispr
  end

  def new
    authorize CrisprModification
    @crispr = CrisprModification.new
    @crispr.build_genomic_integration_site
  end

  def edit
    authorize @crispr
  end

  def create
    authorize CrisprModification
    #render json: params
    #return
    @crispr = CrisprModification.new(crispr_modification_params)

    @crispr.user = current_user

    respond_to do |format|
      if @crispr.save
        format.html { redirect_to @crispr, notice: 'CRISPR Modification was successfully created.' }
        format.json { render json: @crispr, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @crispr.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @crispr
    #render json: params
    #return
    respond_to do |format|
      if @crispr.update(crispr_modification_params)
        format.html { redirect_to @crispr, notice: 'CRISPR Modification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @crispr.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ddestroy(@crispr, redirect_path_success: crispr_modifications_path)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crispr_modification
      @crispr = set_record(controller_name,params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def crispr_modification_params
      params.require(:crispr_modification).permit(
        :category,
        :donor_construct_id,
        :name,
        :notes,
        :prototype,
        :purpose,
        :upstream_identifier,
        document_ids: [],
        crispr_construct_ids: [],
        crispr_constructs_attributes: [:id, :_destroy],
        documents_attributes: [:id,:_destroy],
        genomic_integration_site_attributes: [:id, :chromosome_id, :start, :end]
      )
    end
end
