module MultiSite::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :dev?, :domain
    end
  end
    
  private
    def dev_with_domain?
      prefix = @config["dev.host"] || "dev"
      request.host =~ %r{^#{prefix}\.}
    end
end
