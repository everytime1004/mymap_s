class Api::V1::TripsController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  
  def show
  	

    
  end

end