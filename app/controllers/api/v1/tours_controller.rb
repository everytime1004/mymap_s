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

  protected

  def render_create_success
    render :status => 200,
           :json => { :success => true,
                      :info => "",
                      :data => }
    
  end

  def render_create_error_not_confirmed
    render json: {
      success: false,
      errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
    }, status: 401
  end

  def render_destroy_success
    render :status => 200,
           :json => { :success => true,
                      :info => "" }
  end

  def render_destroy_error
    render json: {
      errors: [I18n.t("devise_token_auth.sessions.user_not_found")]
    }, status: 404
  end



end