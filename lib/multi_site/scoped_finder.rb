module MultiSite::ScopedFinder

  def self.included(base)
    base.class_eval do
      belongs_to :site
      validates_presence_of :site, :message => 'not found' 
      before_validation :set_site
    end

    base.extend ClassMethods
    class << base
      alias_method_chain :find, :site
    end

    def set_site
      self.site ||= self.class.current_site
    end    
  end
  
  module ClassMethods

    def find_with_site(*args)
      raise(MultiSite::SiteNotFound, "no site found", caller) unless Page.current_site && Page.current_site.is_a?(Site)
      Page.current_site.send(self.to_s.pluralize.underscore.intern).find_without_site(*args)
    end

    def current_site
      Page.current_site
    end
    
  end
end

module MultiSite
  class SiteNotFound < Exception; end
end