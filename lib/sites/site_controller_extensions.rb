module Sites::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      before_filter :set_site
    end
  end
  
  # Sets the current site based on the requested host. 
  # No other factors matter in the public site.
  # Site.find_for_host may return (and may create) a default 
  # site if none matches.
  #
  def set_site
    Page.current_site = Site.find_for_host(request.host)
    true
  end
end
