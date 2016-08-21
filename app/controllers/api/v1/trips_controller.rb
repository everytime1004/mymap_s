# encoding: utf-8
class Api::V1::TripsController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  respond_to :json
  def new

  end

  def create

  end

  def destroy

  end

  def show
    params.permit!

    if @trip = Trip.find_by_id(params[:id])
      
      render_show_success
    else
      render_show_error
    end  
  end

  protected

  def render_show_success
    render :status => 200,
           :json => { :success => true,
                      :info => "여행",
                      :data => @trip
                    }
  end

  def render_show_error
    render :status => 401,
           :json => { :success => true,
                      :info => "보시려는 여행은 없습니다. 다시 시도해 주세요."
                    }
  end

  def render_create_success
    render :status => 200,
           :json => { :success => true,
                      :info => "",
                      :data => @trip}
    
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