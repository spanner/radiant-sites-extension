module MultiSite::ControllerExtensions    # for inclusion into ApplicationController
  def self.included(base)

    base.class_eval do
      helper_method :current_site
      prepend_before_filter :set_current_site   # sometimes we need current_site in order to get current_user

      def rescue_action_in_public_with_site(exception)
        case exception
          when ActiveRecord::SiteNotFound
            render :template => "site/not_configured", :layout => false
          else
            rescue_action_in_public_without_site
        end
      end
      alias_method_chain :rescue_action_in_public, :site
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

    def set_current_site
      Page.current_site = current_site
      true
    end

  end
end

