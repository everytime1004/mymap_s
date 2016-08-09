class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable,:omniauthable, :omniauth_providers => [:facebook, :kakao]
  include DeviseTokenAuth::Concerns::User

  has_many :identities, dependent: :destroy
  has_many :tours

  has_many :friendships, dependent: :destroy
  has_many :friends, :through => :friendships

  mount_uploader :image, ImageUploader

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

  validates_presence_of   :email, if: :email_required?
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
  validates_format_of     :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: Devise.password_length, allow_blank: true

  def password_required?
    return false if email.blank?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end

end
