class Api::V1::SessionsController < DeviseTokenAuth::ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  before_action :set_user_by_token, :only => [:destroy]
  after_action :reset_session, :only => [:destroy]
  skip_after_action :update_auth_header, :only => [:create, :destroy]
  
  def new
    render_new_error
  end

  def create
    # Check
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

    @resource = nil
    if field
      q_value = resource_params[field]

      if resource_class.case_insensitive_keys.include?(field)
        q_value.downcase!
      end

      q = "#{field.to_s} = ? AND provider='email'"

      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "BINARY " + q
      end

      @resource = resource_class.where(q, q_value).first

    end
    
    if @resource and valid_params?(field, q_value) and @resource.valid_password?(resource_params[:password])

      # create client id
      sign_in(:user, @resource, store: false, bypass: false)

      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      @resource.save!

      render_create_success
    else
      render_create_error_bad_credentials
    end
  end

  def destroy
    # remove auth instance variables so that after_action does not run
    user = remove_instance_variable(:@resource) if @resource
    client_id = remove_instance_variable(:@client_id) if @client_id
    remove_instance_variable(:@token) if @token
    
    if user and client_id and user.tokens[client_id]
      user.tokens.delete(client_id)
      user.save!

      yield user if block_given?

      render_destroy_success
    else
      # render_destroy_success
      render_destroy_error
    end
  end

  protected

  def valid_params?(key, val)
    resource_params[:password] && key && val
  end

  def get_auth_params
    auth_key = nil
    auth_val = nil

    # iterate thru allowed auth keys, use first found
    resource_class.authentication_keys.each do |k|
      if resource_params[k]
        auth_val = resource_params[k]
        auth_key = k
        break
      end
    end

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(auth_key)
      auth_val.downcase!
    end

    return {
      key: auth_key,
      val: auth_val
    }
  end

  protected

  def render_new_error
    render json: {
      errors: [ I18n.t("devise_token_auth.sessions.not_supported")]
    }, status: 405
  end

  def render_create_success
    render :status => 200,
           :json => { :success => true,
                      :info => "로그인 되었습니다. 환영합니다!",
                      :data => resource_data,
                      :client_id => @resource.tokens.collect{|key, hash| key}.last,
                      :image => (@resource.image.filename ? @resource.image.store_path : ImageUploader.new.default_path),
                      :token => @resource.tokens.collect{|key, hash| hash}.last["token"] }
    
  end

  def render_create_error_not_confirmed
    render json: {
      success: false,
      errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
    }, status: 401
  end

  def render_create_error_bad_credentials
    render :status => 401,
           :json => { :success => true,
                      :info => "로그인 정보를 다시 확인해주세요." }
  end

  def render_destroy_success
    render :status => 200,
           :json => { :success => true,
                      :info => "로그아웃 되었습니다." }
  end

  def render_destroy_error
    render json: {
      errors: [I18n.t("devise_token_auth.sessions.user_not_found")]
    }, status: 404
  end


  private

  def resource_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end
end