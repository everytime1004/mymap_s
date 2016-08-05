OmniAuth.config.full_host = Rails.env.production? ? 'http://zoolu.co.kr' : 'http://localhost:3000'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider( :facebook, Figaro.env.facebook_app_id, Figaro.env.facebook_app_secret )
  provider( :kakao, Figaro.env.kakao_client_id )
end