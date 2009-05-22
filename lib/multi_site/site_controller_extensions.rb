module MultiSite::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :dev?, :domain
    end
  end  
    
  private
    
    # I've removed the configurable dev prefix to eliminate the only remaining database access when the cache is hit
  
    def dev_with_domain?
      request.host =~ /^dev\./
    end
end
