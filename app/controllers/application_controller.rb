class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :generate_stats
  helper_method :current_user

  private

  def generate_stats
    @counts  = Job.state_counts
    @version = Hive::Scheduler.const_get(:VERSION)
  end

  def current_user
    if @current_user.nil?
      user_attributes = if request.headers['bbc.email_address']
                          { name: request.headers['bbc.name'], email: request.headers['bbc.email_address'] }
                        elsif ["test", "development"].include?(Rails.env)
                          { name: "#{Rails.env} user", email: "#{Rails.env}@hive.tld" }
                        end
      @current_user   = User.find_or_create_by(user_attributes)
    end
    @current_user
  end
end
