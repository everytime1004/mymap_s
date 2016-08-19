class Api::V1::ToursController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  
  def new

  end

  def create

  end

  def destroy
  	
  end

  def show

  end



end