class SessionsController < ApplicationController

	skip_before_action :require_login, only: [:login_details]

=begin 
	input : params[:id]
	Add extra user details other than details fetched from the Google+ account.
	Checks whether the user is admin or not.
=end	

	def login_details
		session[:user_id] = params[:id]
		@user = User.find session[:user_id]
		if @user.email == "airmelive@gmail.com"
			redirect_to admins_path
		elsif @user.user_details
			redirect_to profile_path(@user)
		end
	end

=begin
	updates the added details into database.
	updates the edited details into database.
=end

	def update
		@user = User.find(session[:user_id])
    @user.update_attributes(user_params)
    redirect_to profile_path(@user)
  end

=begin
	finds the user profile.
=end  

  def profile
  	@user = User.find(session[:user_id])
  end

=begin 
	edits the user profile.
=end

  def edit
  	@user = User.find(session[:user_id])
  end

=begin 
	logs out from tthe user account.
=end

  def log_out
  	session[:user_id] = nil
  	redirect_to root_url
  end

	private
		def user_params
			params.require(:user).permit(:name, :gplus, :age, :city, :country, :avatar, :likes, :dislikes, :ambition, :talent, :aboutme, :mobile, :email)
		end
end
