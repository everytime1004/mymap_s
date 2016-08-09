class Api::V1::UsersController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  
  def show
  	@user = User.find_by_id(params[:id])
  	uploader = ImageUploader.new
  	@image_path  = uploader.default_path

    
  end

end