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
    @projects = Project.all.select {|p| p.latest_batch != nil }.sort { |a, b| b.latest_batch.updated_at <=> a.latest_batch.updated_at }[0, 10]
  end

  def current_user
    if @current_user.nil? and request.headers['bbc.email_address']
      @current_user = User.find_or_create_by(
                              name: request.headers['bbc.name'],
                              email: request.headers['bbc.email_address'])
    end
    @current_user
  end
end
