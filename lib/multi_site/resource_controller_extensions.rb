module MultiSite::ResourceControllerExtensions

  def self.included(base)
    base.class_eval {
      helper_method :current_site
      before_filter :set_site
    }
  end

  # some inheriting (admin) controllers have their own ideas about where site information should be found
  # resource controllers look for a site_id parameter and admin::pagecontroller also looks for a root= parameter

  def current_site
    Page.current_site
  end

  def current_site=(site=nil)
    if site && site.is_a?(Site)
      Page.current_site = site
      set_session_site
    end
  end

protected

  def set_site
    current_site = discover_current_site
  end
  
  # chains attach here

  def discover_current_site
    site_from_param || site_from_session
  end

  # various ways to pass around site id. More in subclasses
  
  def site_from_session
    session[:site_id] && Site.find(session[:site_id]) rescue nil
  end

  def site_from_param
    params[:site_id] && Site.find(params[:site_id]) rescue nil
  end

  # for interface consistency we want to be able to remember site choices between requests
  
  def set_session_site(site_id=nil)
    session[:site_id] = site_id || current_site.id.to_s
  end

end
