module MultiSite::BaseExtensions
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def is_site_scoped
      include MultiSite::ScopedFinder unless is_site_scoped?
    end
    
    def is_site_scoped?
      included_modules.include?(MultiSite::ScopedFinder)
    end
  end
end
