module MultiSite::ControllerExtensions    # for inclusion into ApplicationController
  def self.included(base)

    base.class_eval do
      helper_method :current_site
      prepend_before_filter :set_current_site   # sometimes we need current_site in order to get current_user
    end

    def current_site
      @current_site || self.current_site = find_current_site
    end
    
    def current_site=(site=nil)
      if site && site.is_a?(Site)
        @current_site = site
      end
    end

    # this is separated out so it can be alias_chained
    # in eg resource controller and pages controller
    
    def find_current_site
      site_from_host
    end
    
    def site_from_host
      Site.find_for_host(request.host) # defaults to first site with empty domain if none match request domain
    end

    def set_current_site
      Page.current_site = current_site
      true
    end

  end
end

