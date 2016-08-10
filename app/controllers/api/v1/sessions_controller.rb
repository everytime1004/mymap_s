class Api::V1::SessionsController < DeviseTokenAuth::ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  before_action :set_user_by_token, :only => [:destroy]
  after_action :reset_session, :only => [:destroy]

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
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }
      @resource.save

      sign_in(:user, @resource, store: false, bypass: false)

      yield @resource if block_given?

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
                      :image => (@resource.image.filename ? @resource.image.store_path : ImageUploader.new.default_url),
                      :client_id => @resource.tokens.collect{|key, hash| key}.last,
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

  def set_user_by_token(mapping=nil)
    # determine target authentication class
    rc = resource_class(mapping)

    # no default user defined
    return unless rc

    #gets the headers names, which was set in the initialize file
    uid_name = DeviseTokenAuth.headers_names[:'uid']
    access_token_name = DeviseTokenAuth.headers_names[:'access-token']
    client_name = DeviseTokenAuth.headers_names[:'client']

    # parse header for values necessary for authentication
    uid        = request.headers[uid_name] || params[uid_name]
    @token     ||= request.headers[access_token_name] || params[access_token_name]
    @client_id ||= request.headers[client_name] || params[client_name]

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # check for an existing user, authenticated via warden/devise, if enabled
    if DeviseTokenAuth.enable_standard_devise_support
      devise_warden_user = warden.user(rc.to_s.underscore.to_sym)
      if devise_warden_user && devise_warden_user.tokens[@client_id].nil?
        @used_auth_by_token = false
        @resource = devise_warden_user
        @resource.create_new_auth_token
      end
    end
    
    # user has already been found and authenticated
    return @resource if @resource and @resource.class == rc

    # ensure we clear the client_id
    if !@token
      @client_id = nil
      return
    end

    return false unless @token
    # mitigate timing attacks by finding by uid instead of auth token
    user = uid && rc.find_by_uid(uid)
    print "||||\n\n|||||"
    print user.tokens
    print "||||\n\n|||||"
    print @token
    print "||||\n\n|||||"
    print @client_id

    print "||||\n\n|||||"

    if user && user.valid_token?(@token, @client_id)
      # sign_in with bypass: true will be deprecated in the next version of Devise
      if self.respond_to? :bypass_sign_in
        bypass_sign_in(user, scope: :user)
      else
        sign_in(:user, user, store: false, bypass: true)
      end
      return @resource = user
    else
      # zero all values previously set values
      @client_id = nil
      return @resource = nil
    end
  end

  def valid_token?(token, client_id='default')
    client_id ||= 'default'

    print self
    print "||||\n\n|||||"
    a

    return false unless self.tokens[client_id]

    return true if token_is_current?(token, client_id)
    return true if token_can_be_reused?(token, client_id)

    # return false if none of the above conditions are met
    return false
  end

end