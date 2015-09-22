
class User < ActiveRecord::Base

  def self.find_or_create_from_omniauth_hash(creds)
    User.where( provider: creds[:provider], uid: creds[:uid] ).first_or_create do |user|
          user.email = creds[:email]
          user.name = creds[:name]
    end
  end

  def self.anonymous_user
    User.find_or_create_by(:uid => 'anonymous', :provider => 'default')
  end

end
