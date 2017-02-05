class LibrarySequencingResultsController < ApplicationController
  before_action :set_library_sequencing_result, only: [:show, :edit, :update, :destroy]
	before_action :set_sequencing_result

  # GET /library_sequencing_results
  # GET /library_sequencing_results.json
  def index
    @library_sequencing_results = LibrarySequencingResult.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @library_sequencing_results }
    end
  end

  # GET /library_sequencing_results/1
  # GET /library_sequencing_results/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @library_sequencing_result }
    end
  end

  # GET /library_sequencing_results/new
  def new
    @library_sequencing_result = @sequencing_result.build
  end

  # GET /library_sequencing_results/1/edit
  def edit
		authorize @library_sequencing_result
  end

  # POST /library_sequencing_results
  # POST /library_sequencing_results.json
  def create
    @library_sequencing_result = LibrarySequencingResult.new(library_sequencing_result_params)
		authorize @library_sequencing_result

    respond_to do |format|
      if @library_sequencing_result.save
        format.html { redirect_to @library_sequencing_result, notice: 'Library sequencing result was successfully created.' }
        format.json { render json: @library_sequencing_result, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @library_sequencing_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /library_sequencing_results/1
  # PATCH/PUT /library_sequencing_results/1.json
  def update
		authorize @library_sequencing_result@
    respond_to do |format|
      if @library_sequencing_result.update(library_sequencing_result_params)
        format.html { redirect_to @library_sequencing_result, notice: 'Library sequencing result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @library_sequencing_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /library_sequencing_results/1
  # DELETE /library_sequencing_results/1.json
  def destroy
    @library_sequencing_result.destroy
    respond_to do |format|
      format.html { redirect_to library_sequencing_results_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_library_sequencing_result
      @library_sequencing_result = LibrarySequencingResult.find(params[:id])
    end

		def set_sequencing_result
			@sequencing_result = SequencingResult.find(params[:sequencing_result_id])
		end

    # Never trust parameters from the scary internet, only allow the white list through.
    def library_sequencing_result_params
      params.require(:library_sequencing_result).permit(:name, :sequencing_result_id, :library_id, :comment, :read1_uri, :read2_uri, :read1_count, :read2_count)
    end
end