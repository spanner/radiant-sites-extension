# This is included into ApplicationController and outlines the basic machinery of site detection. By itself, it only looks at the request host, which is correct for the public site. 
# Controllers within the admin space will add more ways of picking up the right site, including request parameters and session values.

module MultiSite::ControllerExtensions 
  def self.included(base)

    base.class_eval do
      helper_method :current_site
      prepend_before_filter :set_current_site   # sometimes we need current_site in order to get current_user
    end
    
    # the first time current_site is called, it will call find_current_site. Results are stored in the class variable @current_site and subsequently have to be updated by called current_site= rather than changing context.
    # we call self.current_site= rather than setting @current_site so that the setter method can be extended down the line.

    def current_site
      @current_site || self.current_site = find_current_site
    end
    
    # current_site= will only act if a site is supplied: called current_site = nil has no effect.
    
    def current_site=(site=nil)
      if site && site.is_a?(Site)
        @current_site = site
      end
    end

    protected
    
      # set_current_site is the starting point of the site-context machinery. It is invoked from a before_filter and sets Page.current_site in a way that calls (once) find_current_site

      def set_current_site
        Page.current_site = current_site
        true
      end

      # find_current_site is separated so it can be alias_chained
      # in eg resource controller (adds site_id= param and checks admin session) and pages controller (adds root= param)

      def find_current_site
        site_from_host
      end

      # site_from_host just calls Site.find_for_host.

      def site_from_host
        Site.find_for_host(request.host) # defaults to first site with empty domain if none match request domain
      end

  end
end

