module MultiSite::ApplicationControllerExtensions

  def self.included(base)
    base.class_eval {
      prepend_before_filter :set_site
      helper_method :current_site, :current_site=
    }
  end

  def current_site
    Page.current_site
  end

  def current_site=(site=nil)
    Page.current_site = site
  end

protected

  def set_site
    true if self.current_site = discover_current_site
  end
  
  # chains will attach here
  
  def discover_current_site
    site_from_host
  end
  
  # and add more ways to determine the current site
  
  def site_from_host
    Site.find_for_host(request.host)
  end

end
