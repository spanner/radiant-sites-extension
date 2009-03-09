module MultiSite::ControllerExtensions    # for inclusion into ApplicationController
  def self.included(base)

    base.class_eval do
      helper_method :current_site
      prepend_before_filter :set_current_site   # sometimes we need current_site in order to get current_user
    end

    def current_site
      @current_site || current_site = Site.find_for_host(request.host) # defaults to first site with empty domain if none match
    end
    
    def current_site=(value=nil)
      if value && value.is_a?(Site)
        @current_site = value
      end
    end

    def set_site_cookie
      cookies[:site_id] = { :value => current_site.id.to_s }
    end
    
    def site_from_cookie
      if !cookies[:site_id].blank? && site = Site.find(cookies[:site_id])
        site
      end
    end

  # protected
  
    def set_current_site
      Page.current_site = current_site
      true
    end
  end
end

