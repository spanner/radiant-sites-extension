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
      @current_site || self.current_site = find_current_site
    end
    
    # this is separate here so it can be alias_chained in eg pages_controller
    
    def find_current_site 
      site_from_param || site_from_cookie || site_from_host
    end

    def current_site=(site=nil)
      if site && site.is_a?(Site)
        @current_site = site
        cookies[:site_id] = { :value => site.id.to_s }
      end
    end

    def site_from_cookie
      cookies[:site_id] && Site.find(cookies[:site_id]) rescue nil
    end

    def site_from_param
      params[:site_id] && Site.find(params[:site_id]) rescue nil
    end

    def site_from_host
      Site.find_for_host(request.host) # defaults to first site with empty domain if none match better
    end

    def set_current_site
      Page.current_site = current_site
      true
    end

    def set_site_cookie(site_id=nil)
      cookies[:site_id] = { :value => site_id || current_site.id.to_s }
    end

  end
end

