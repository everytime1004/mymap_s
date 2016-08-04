class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :kakao]

  has_many :identities


  def facebook
    identities.where( :provider => "facebook" ).first
  end

  def facebook_client
    @facebook_client ||= Facebook.client( access_token: facebook.accesstoken )
  end
 
  def kakao
    identities.where( :provider => "kakao" ).first
  end

  def kakao_client
    @kakao_client ||= Kakao.client( access_token: kakao.accesstoken )
  end

end
