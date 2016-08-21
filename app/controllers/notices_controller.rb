class NoticesController < ActionController::Base

  def index
  	@notices = Notices.all
  end
end
