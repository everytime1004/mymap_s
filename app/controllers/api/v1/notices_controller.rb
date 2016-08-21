# encoding: utf-8
class Api::V1::NoticesController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  
  def index
  	@notices = Notice.all

  	render :status => 200,
           :json => { :success => true,
                      :info => "완료 되었습니다.",
                      :data => @notices }
  end

end