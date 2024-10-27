module Omniauthable
  extend ActiveSupport::Concern

  class_methods do
    def from_omniauth(auth)
      user = User.where(email: auth.info.email).first

      if user
        user.update(
          provider: auth.provider,
          uid: auth.uid,
          access_token: auth.credentials.token,
          refresh_token: auth.credentials.refresh_token
        )
      else
        user = User.create(
          email: auth.info.email,
          name: auth.info.name,
          password: Devise.friendly_token[0, 20],
          provider: auth.provider,
          uid: auth.uid,
          access_token: auth.credentials.token,
          refresh_token: auth.credentials.refresh_token
        )
      end

      user
    end
  end
end
