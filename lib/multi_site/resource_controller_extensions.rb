module MultiSite::ResourceControllerExtensions

  def self.included(base)
    base.class_eval {
      prepend_before_filter :set_site
      helper_method :current_site
    }
  end

  def current_site
    Page.current_site
  end

  def current_site=(site=nil)
    Page.current_site = site
    set_session_site
  end

protected

  def set_site
    true if self.current_site = discover_current_site
  end
  
  # chains attach here
  
  def discover_current_site
    site_from_param || site_from_session || site_from_host
  end

  # ...to add to or replace this set of ways to determine site id.
  
  def site_from_host
    Site.find_for_host(request.host)
  end
  
  def site_from_session
    session[:site_id] && Site.find(session[:site_id]) rescue nil
  end

  def site_from_param
    params[:site_id] && Site.find(params[:site_id]) rescue nil
  end

  # for interface consistency we want to be able to remember site choices between requests
  
  def set_session_site(site_id=nil)
    site_id ||= current_site.id.to_s if current_site.is_a? Site
    session[:site_id] = site_id
  end

end
