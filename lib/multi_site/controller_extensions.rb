module MultiSite::ControllerExtensions
  def self.included(base)
    base.class_eval do
      helper_method :current_site
      before_filter :set_current_site
    end

    def current_site
      @current_site || current_site = Site.find_for_host(request.host)
    end
    
    def current_site=(value=nil)
      if value && value.is_a?(Site)
        @current_site = value
      end
    end

  end
  
  private
  
    def set_current_site
      Page.current_site = current_site
      true
    end

end
