class Api::V1::UsersController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  respond_to :json
  def show
  	

    
  end

end