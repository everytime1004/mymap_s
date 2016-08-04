class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

	skip_before_filter :authenticate_user!
	
	def facebook
    generic_callback( 'facebook' )
  end

  def kakaotalk
    generic_callback( 'kakao' )
  end


  def generic_callback( provider )
    @identity = Identity.find_for_oauth env["omniauth.auth"]

    @user = @identity.user || current_user
    if @user.nil?
      begin
        # if email exists error is occured and redirect to root_path with params[:error]
        @user = User.create( email: @identity.email || "" )
        @identity.update_attribute( :user_id, @user.id )
      rescue => e
        # redirect is not worked until method is finished so add return
        return redirect_to root_url(error: "#{e.message}")
      end
    end

    if @user.email.blank? && @identity.email
      @user.update_attribute( :email, @identity.email)
    end

    if @user.persisted?
      @identity.update_attribute( :user_id, @user.id )
      # event: :authentication warden callback
      # http://stackoverflow.com/questions/9221390/what-does-event-authentication-do/13389324#13389324
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end


  def setup
    request.env['omniauth.strategy'].options['scope'] = flash[:scope] || request.env['omniauth.strategy'].options['scope']
    render :text => "Setup complete.", :status => 404
  end

end