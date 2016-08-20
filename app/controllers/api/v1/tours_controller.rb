class Api::V1::ToursController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  
  def new

  end

  def create
    params.permit!
    @user = User.find_by_id(parmas[:user][:id])

    if @tour = @user.tours.create
      @tour.trips.create
      render_create_success
    else
      render_create_error
    end  

  end

  def destroy

  end

  def show
    params.permit!

    if @tour = Tour.find_by_id(params[:id])
      
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
                      :data => @tour,
                      :trips => @tour.trips.collect{|trip| trip.id}
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
                      :info => "여행을 시작합니다.",
                      :data => @trip.id}
    
  end

  def render_create_error
    render :status => 401,
           :json => { :success => true,
                      :info => "여행 생성 실패 다시 시도해주세요."
                    }
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