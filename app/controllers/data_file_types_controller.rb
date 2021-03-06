class DataFileTypesController < ApplicationController
  before_action :set_data_file_type, only: [:show, :edit, :update, :destroy]

  def select_options                                                                                   
    #Called via ajax.                                                                                  
    #Typically called when the user selects the refresh icon in any form that has a data_file_types selection.
    @records = DataFileType.all
    render "application_partials/select_options", layout: false                                        
  end

  def index
    super
  end

  def show
    authorize @data_file_type
  end

  def new
    authorize DataFileType
    @data_file_type = DataFileType.new
  end

  def edit
    authorize @data_file_type
  end

  def create
    authorize DataFileType
    @data_file_type = DataFileType.new(data_file_type_params)
    @data_file_type.user = current_user

    respond_to do |format|
      if @data_file_type.save
        format.html { redirect_to @data_file_type, notice: 'Data file type was successfully created.' }
        format.json { render json: @data_file_type, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @data_file_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @data_file_type
    respond_to do |format|
      if @data_file_type.update(data_file_type_params)
        format.html { redirect_to @data_file_type, notice: 'Data file type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @data_file_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ddestroy(@data_file_type, redirect_path_success: data_files_path)
  end

  private
    def set_data_file_type
      @data_file_type = set_record(controller_name,params[:id]) #set_record defined in application_controller.rb
    end

    def data_file_type_params
      params.require(:data_file_type).permit(
        :name, 
        :notes,
        :description
      )
    end
end
