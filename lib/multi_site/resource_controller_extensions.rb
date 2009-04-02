module MultiSite::ResourceControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :find_current_site, :options
    }
  end

  def current_site=(site=nil)
    if site && site.is_a?(Site)
      @current_site = site
      set_session_site
    end
  end

  def find_current_site_with_options
    site_from_param || site_from_session || find_current_site_without_options
  end

  def site_from_session
    session[:site_id] && Site.find(session[:site_id]) rescue nil
  end

  def site_from_param
    params[:site_id] && Site.find(params[:site_id]) rescue nil
  end

  def set_session_site(site_id=nil)
    session[:site_id] = site_id || current_site.id.to_s
  end

end
