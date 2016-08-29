class BiosamplesController < ApplicationController
  before_action :set_biosample, only: [:show, :edit, :update, :destroy]

  # GET /biosamples
  # GET /biosamples.json
  def index
    @biosamples = Biosample.all
  end

  # GET /biosamples/1
  # GET /biosamples/1.json
  def show
  end

  # GET /biosamples/new
  def new
    @biosample = Biosample.new
  end

  # GET /biosamples/1/edit
  def edit
  end

  # POST /biosamples
  # POST /biosamples.json
  def create
		#documents could be a string containing a document ID, or an array of strings, where each string identifies a document id. 
    @biosample = Biosample.new(biosample_params)
		add_document()	
		
    respond_to do |format|
      if @biosample.save
        format.html { redirect_to @biosample, notice: 'Biosample was successfully created.' }
        format.json { render action: 'show', status: :created, location: @biosample }
      else
        format.html { render action: 'new' }
        format.json { render json: @biosample.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biosamples/1
  # PATCH/PUT /biosamples/1.json
  def update
		add_document()
    respond_to do |format|
      if @biosample.update(biosample_params)
        format.html { redirect_to @biosample, notice: 'Biosample was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @biosample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biosamples/1
  # DELETE /biosamples/1.json
  def destroy
    @biosample.destroy
    respond_to do |format|
      format.html { redirect_to biosamples_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_biosample
      @biosample = Biosample.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def biosample_params
      params.require(:biosample).permit(:submitter_comments, :lot_identifier, :source_product_identifier, :term_name, :term_identifier, :description, :passage_number, :culture_harvest_date, :encid, :human_donor_id,:vendor_id,:biosample_type_id)
    end

		def add_document
			document = params[:biosample][:documents]
			if not document.empty?
				document = Document.find(document)
				@biosample.documents << document
			end
		end
end
