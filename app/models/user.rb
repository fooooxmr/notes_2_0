class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true,
                      confirmation: true,
                      length: { within: 6..40 }, unless: :token_exists

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.token = auth.credentials.token
      user.expires = auth.credentials.expires
      user.expires_at = auth.credentials.expires_at
      user.refresh_token = auth.credentials.refresh_token
      user.email = auth.extra.id_info.email
    end
  end

  private

  def token_exists
    token
  end
end
