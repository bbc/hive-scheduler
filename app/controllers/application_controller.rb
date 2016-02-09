class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :generate_stats, :except => :status
  helper_method :current_user

  # Omniauth callback handler when using force_authentication
  def auth_callback
    current_user
    omniauth_origin = session[:omniauth_origin]
    session.delete(:omniauth_origin)
    redirect_to omniauth_origin || '/'
  end
  
  private

  def generate_stats
    @counts  = Rails.cache.fetch('sidebar_counts', expires_in: 1.minute) do
      Job.state_counts
    end
    
    @version = Hive::Scheduler.const_get(:VERSION)
    
    
    @sidebar_projects = Rails.cache.fetch('sidebar_projects', expires_in: 1.minute) do
      Project.all.includes(:latest_batch).select {|p| p.latest_batch != nil }.sort { |a, b| b.latest_batch.updated_at <=> a.latest_batch.updated_at }[0, 10]
    end

  end

  private

  def current_user
    if @current_user.nil?
      if session[:user_id]
        @current_user = User.find(session[:user_id])
      elsif omniauth_credentials
        creds = omniauth_credentials
        @current_user = User.find_or_create_from_omniauth_hash(creds)
      end
    
      if @current_user.nil?
        # If force_authentication is set, automatically redirect to the default sign-in
        if Rails.application.config.force_authentication
          if !session[:omniauth_origin]
            session[:omniauth_origin] = request.original_url
            redirect_to('/auth/' + Rails.application.config.default_omniauth_provider.to_s )
          end
        end
      end
 
      session[:user_id] = @current_user.id if @current_user
    end
    @current_user || User.anonymous_user
  end
  
  # Extract omniauth credentials from the request environment
  def omniauth_credentials
    if omniauth_hash = request.env['omniauth.auth']
      {
        provider: omniauth_hash['provider'],
        uid:      omniauth_hash['uid'],
        email:    omniauth_hash['info']['email'],
        name:     omniauth_hash['info']['name'],
      }
    else
      nil
    end
  end

end
