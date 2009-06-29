module MultiSite::ResourceControllerExtensions

  def self.included(base)
    base.class_eval {
      before_filter :set_current_site
      alias_method_chain :find_current_site, :options
    }
  end

  def current_site=(site=nil)
    if site && site.is_a?(Site)
      @current_site = site
      Page.current_site = site
      set_session_site
    end
  end

  # set_current_site is moved into here because the alternative ways of setting the site only matter in admin
  # for site_controller, it is always right to use the site corresponding to request.host
  # and we can do that just by setting Page.current_domain
  # the main advantage is to eliminate any database calls from the trip to a cache hit

  def set_current_site
    Page.current_site = current_site
    true
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
