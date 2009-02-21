module MultiSite::ScopedFinder

  def self.included(base)
    base.class_eval do
      belongs_to :site
      validates_presence_of :site, :message => 'not found'      # ought to be redundant
      before_validation :set_site
    end

    Site.send(:has_many, base.to_s.pluralize.underscore.intern)
    base.extend ClassMethods

    class << base
      alias_method_chain :find, :site
      alias_method_chain :count, :site
    end

    def set_site
      self.class.check_current_site
      self.site ||= self.class.current_site
    end    
  end
  
  module ClassMethods

    def find_with_site(*args)
      check_current_site
      current_site.send(self.to_s.pluralize.underscore.intern).find_without_site(*args)
    end

    def count_with_site(*args)
      check_current_site
      current_site.send(self.to_s.pluralize.underscore.intern).count_without_site(*args)
    end

    def current_site
      Page.current_site
    end
    
    def check_current_site
      raise(MultiSite::SiteNotFound, "no site found", caller) unless current_site && current_site.is_a?(Site)
    end
    
  end
end

module MultiSite
  class SiteNotFound < Exception; end
end