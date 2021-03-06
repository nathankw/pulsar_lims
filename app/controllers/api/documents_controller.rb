class Api::DocumentsController < Api::ApplicationController
  #example with curl:
  # curl -H "Authorization: Token token=${token}" http://localhost:3000/api/documents/3
  before_action :set_document, only: [:show, :destroy, :update, :download]

  def find_by
    # find_by defined in ApplicationController#find_by.
    # Use this method when you want to AND all of your query parameters.
    super
  end

  def find_by_or
    # find_by_or defined in ApplicationController#find_by_or.
    # Use this method when you want to OR all of your query parameters.
    super
  end

  def download
    authorize @document, :show?
    # Base64 encode binary stream. Client will need to base64 decode it.
    render json: {"data": Base64.encode64(@document.data)}
  end

  def index
    @documents = policy_scope(Document).order("lower(name)")
    render json: @documents
  end

  def show
    authorize @document
    render json: @document
  end

  def create
    @document = Document.new(document_params)
    # The data attribute (document body) should be base64 encoded and then converted into a string 
    # (i.e. UTF-8 encoded), which the Pulsarpy client already does when calling this endpoint.
    data = Base64.decode64(@document.data)
    @document.data = data
    @document.user = @current_user
    authorize @document
    if @document.save
      render json: @document, status: 201
    else
      render json: { errors: @document.errors.full_messages }, status: 422
    end
  end

  def update
    authorize @document
    if @document.update(document_params)
      render json: @document, status: 200
    else
      render json: { errors: @document.errors.full_messages }, status: 422
    end
  end

  def destroy
    ddestroy(@document)
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :user_id,
      :content_type,
      :data,
      :description,
      :document_type_id,
      :is_protocol,
      :name,
      :notes,
      :upstream_identifier
    )
  end
end
