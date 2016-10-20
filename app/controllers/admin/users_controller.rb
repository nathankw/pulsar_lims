class Admin::UsersController < Admin::ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy, :archive]

  def index
		@admins = User.admin_users
		@users = User.regular_users
		@archived = User.archived_users
  end

	def show
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, notice: "User was successfully created." }
        format.json { render action: "index", status: :created, location: admin_users_path }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end 
    end 
  end 

	def edit
	end

	def update
		if params[:user][:password].blank?
			params[:user].delete(:password)
		end
		
		respond_to do |format|
			if @user.update(user_params)
				format.html { redirect_to admin_users_path, notice: "User was successfully updated."}
				format.json { head :no_content }
			else
				format.html { render :edit }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end
				
	def destroy
		@user.destroy
		respond_to do |format|
			format.html { redirect_to admin_users_url, notice: "User was successfully deleted." }
			format.json { head :no_content }
		end
	end

	def archive
		if @user == current_user
			respond_to do |format|
				flash.now[:alert] =  "You cannot archive yourself."
				format.html { render "show" }
			end
			return
		end

		@user.archive
		
		respond_to do |format|
			format.html { redirect_to admin_users_path, notice: "User was successfully archived." }
			format.json { head :no_content }
		end
	end

	private
		def user_params
			params.require(:user).permit(:email, :password, :admin)
		end

		def set_user
			@user = User.find(params[:id])
		end
end