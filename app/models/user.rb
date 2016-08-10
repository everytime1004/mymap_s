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

  def tokens_match?(token_hash, token)
    @token_equality_cache ||= {}
    key = "#{token_hash}/#{token}"
    result = @token_equality_cache[key] ||= (::BCrypt::Password.new(token_hash).to_s == token)
    print "\n\n|||||||||||||||||\n\n"
    print key
    print "\n\n|||||||||||||||||\n\n"
    print result
    print "\n\n|||||||||||||||||\n\n"

    if @token_equality_cache.size > 10000
      @token_equality_cache = {}
    end
    result
  end
  def valid_token?(token, client_id='default')

    client_id ||= 'default'
    
    return false unless self.tokens[client_id]

    return true if token_is_current?(token, client_id)
    return true if token_can_be_reused?(token, client_id)

    # return false if none of the above conditions are met
    return false
  end

  def token_is_current?(token, client_id)
    # ghetto HashWithIndifferentAccess
    expiry     = self.tokens[client_id]['expiry'] || self.tokens[client_id][:expiry]
    token_hash = self.tokens[client_id]['token'] || self.tokens[client_id][:token]
    
    return true if (
      # ensure that expiry and token are set
      expiry and token and

      # ensure that the token has not yet expired
      DateTime.strptime(expiry.to_s, '%s') > Time.now and

      # ensure that the token is valid
      self.tokens_match?(token_hash, token)
    )
  end

end
