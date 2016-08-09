# encoding: utf-8
class Api::V1::RegistrationsController < DeviseTokenAuth::ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  respond_to :json

  def create
    @resource            = resource_class.new(sign_up_params)
    @resource.provider   = "email"

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @resource.email = sign_up_params[:email].try :downcase
    else
      @resource.email = sign_up_params[:email]
    end

    # # give redirect value from params priority
    # @redirect_url = params[:confirm_success_url]

    # # fall back to default value if provided
    # @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

    # # success redirect url is required
    # if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
    #   return render_create_error_missing_confirm_success_url
    # end

    # # if whitelist is set, validate redirect_url against whitelist
    # if DeviseTokenAuth.redirect_whitelist
    #   unless DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
    #     return render_create_error_redirect_url_not_allowed
    #   end
    # end
    
    begin
      # override email confirmation, must be sent manually from ctrl
      resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        yield @resource if block_given?

        # email auth has been bypassed, authenticate user
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {        
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }

        @resource.save!

        update_auth_header
      
        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render_create_error_email_already_exists
    end
  end

  def update
    @user = User.find_by_id(params[:id])

    @user.update_attributes(name: params[:user][:name], gender: params[:user][:gender], birth: params[:user][:birth], birth_year: params[:user][:birth].split("/")[0])

    if params[:user][:pictureChanged]
      @image = Base64.decode64(params[:user][:image])

      tempFile = Tempfile.new("tempFile")
      tempFile.binmode
      tempFile.write(@image)

      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempFile, :filename => "UserPicture_#{params[:id]}.jpg")

      @user.photos.first.destroy if(@user.photos != [])

      @user.photos.create(image: uploaded_file)

      @user.update_attributes(image_url: "http://14.63.168.158#{@user.photos.last.to_s}")

      render :status => 200,
             :json => { :success => true,
                        :info => "유저 정보를 업데이트 하였습니다.",
                        :data => { name: @user.name, 
                                   email: @user.email,
                                   gender: @user.gender,
                                   birth: @user.birth,
                                   image: @user.photos.first.image.to_s } }
    else
      if @user.photos != []
        render :status => 200,
               :json => { :success => true,
                          :info => "유저 정보를 업데이트 하였습니다.",
                          :data => { name: @user.name, 
                                     email: @user.email,
                                     gender: @user.gender,
                                     birth: @user.birth,
                                     image: @user.photos.first.image.to_s } }
      else
        render :status => 200,
               :json => { :success => true,
                          :info => "유저 정보를 업데이트 하였습니다.",
                          :data => { name: @user.name, 
                                     email: @user.email,
                                     gender: @user.gender,
                                     birth: @user.birth,
                                     image: {} } }
      end
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    if @user.destroy
      render :status => 200,
             :json => { :success => true,
                        :info => "탈퇴 되었습니다.",
                        :data => {} }
    else
      render :status => 401,
             :json => { :success => true,
                        :info => "문제가 발생되었습니다. 다시 시도해주세요.",
                        :data => {} }
    end                        
  end

  protected


  def render_create_error_missing_confirm_success_url
    render json: {
      status: 'error',
      data:   resource_data,
      errors: [I18n.t("devise_token_auth.registrations.missing_confirm_success_url")]
    }, status: 422
  end

  def render_create_error_redirect_url_not_allowed
    render json: {
      status: 'error',
      data:   resource_data,
      errors: [I18n.t("devise_token_auth.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)]
    }, status: 422
  end

  def render_create_success
    render :status => 200,
           :json => { :success => true,
                      :info => "회원가입이 되었습니다. 환영합니다!",
                      :data => resource_data,
                      :image => (@resource.image.filename ? @resource.image.store_path : ImageUploader.new.default_url),
                      :token => @resource.tokens.collect{|key, hash| hash}.last["token"] }
                      # @resource.tokens하면 hash로 나오는데 거기서 token만 뽑기위해서 collect함.
                      #여기서 토큰이 여러개 생길 수 있기 때문에 가장 최근에 생긴 .last에서 token을 뽑음
  end

  def render_create_error
    print "error"
    render :status => 401,
           :json => { :success => true,
                      :info => resource_errors,
                      :data => resource_data }
  end

  def render_create_error_email_already_exists
    print "exists email"
    render :status => 401,
           :json => { :success => true,
                      :info => "이미 메일이 존재합니다.",
                      :data => resource_data }
  end

  def render_update_success
    render json: {
      status: 'success',
      data:   resource_data
    }
  end

  def render_update_error
    render json: {
      status: 'error',
      errors: resource_errors
    }, status: 422
  end

  def render_update_error_user_not_found
    render json: {
      status: 'error',
      errors: [I18n.t("devise_token_auth.registrations.user_not_found")]
    }, status: 404
  end

  def render_destroy_success
    render json: {
      status: 'success',
      message: I18n.t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.uid)
    }
  end

  def render_destroy_error
    render json: {
      status: 'error',
      errors: [I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")]
    }, status: 404
  end

  private

  def resource_update_method
    if DeviseTokenAuth.check_current_password_before_update == :attributes
      "update_with_password"
    elsif DeviseTokenAuth.check_current_password_before_update == :password and account_update_params.has_key?(:password)
      "update_with_password"
    elsif account_update_params.has_key?(:current_password)
      "update_with_password"
    else
      "update_attributes"
    end
  end

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

end