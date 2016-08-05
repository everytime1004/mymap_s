# encoding: utf-8
class Api::V1::RegistrationsController < Devise::RegistrationsController

  respond_to :json

  def create
    build_resource
    
    if resource.save
      sign_in resource

      render :status => 200,
           :json => { :success => true,
                      :info => "회원가입이 되었습니다. 환영합니다!",
                      :data => { :user => resource,
                                 :auth_token => current_user.authentication_token,
                                 :user_id => current_user.id } }
    else
      render :status => 401,
             :json => { :success => true,
                        :info => resource.errors,
                        :data => { }
                      }
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

end