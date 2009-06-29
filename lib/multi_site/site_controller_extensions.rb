module MultiSite::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :dev?, :tld
      alias_method_chain :show_uncached_page, :site
    end
  end  
    
  private
  
    # site-finder is postponed until after the cache has been tried

    def show_uncached_page_with_site(url)
      Page.current_site = current_site
      show_uncached_page_without_site(url)
    rescue ActiveRecord::SiteNotFound     # shouldn't ever happen!
      flash[:error] = "No default site"
      redirect_to welcome_url
    end
    
    # I've removed the configurable dev prefix to eliminate the only remaining database access before a cache hit
    # so dev sites have to have domains that end with .dev
    # which is very easy to set up with ghost.
    
    def dev_with_tld?
      request.host =~ /\.dev$/
    end
end
