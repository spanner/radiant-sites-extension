module MultiSite::ControllerExtensions    # for inclusion into ApplicationController
  def self.included(base)

    base.class_eval do
      helper_method :current_site
      prepend_before_filter :set_current_site   # sometimes we need current_site in order to get current_user
    end

    def current_site
      @current_site ||= find_current_site
    end
    
    def current_site=(site=nil)
      if site && site.is_a?(Site)
        @current_site = site
      end
    end

    protected
    
      # set_current_site asks for current_site, which calls (and remembers) find_current_site

      def set_current_site
        Page.current_site = current_site
        true
      end

      # this is separated so it can be alias_chained
      # in eg resource controller (adds site_id= param and checks admin session) and pages controller (adds root= param)

      def find_current_site
        site_from_host
      end

      def site_from_host
        Site.find_for_host(request.host) # defaults to first site with empty domain if none match request domain
      end

  end
end

