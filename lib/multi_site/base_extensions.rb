module MultiSite::BaseExtensions
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def is_site_scoped
      include MultiSite::ScopedFinder
    end
  end
end
