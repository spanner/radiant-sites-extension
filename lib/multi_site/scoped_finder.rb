module MultiSite::ScopedFinder

  def self.included(base)
    base.class_eval do
      belongs_to :site
      validates_presence_of :site, :message => 'not found'      # ought to be redundant
      before_validation :set_site
    end

    Site.send(:has_many, base.to_s.pluralize.underscore.intern)
    base.extend ClassMethods

    # all (?) find operations, including attribute-based finders, end up calling find_every
    # so we extend that rather than trying to guess all the variations

    class << base
      %w{find_every count average minimum maximum sum}.each do |getter|
        alias_method_chain getter.intern, :site
      end
    end

    def set_site
      self.class.check_current_site
      self.site ||= self.class.current_site
    end    
  end
  
  module ClassMethods
    %w{find_every count average minimum maximum sum}.each do |getter|
      define_method("#{getter}_with_site") do |*args|
        check_current_site
        current_site.send(self.to_s.pluralize.underscore.intern).send("#{getter}_without_site".intern, *args)
      end
    end
    
    # def find_every_with_site(*args)
    #   check_current_site
    #   current_site.send(self.to_s.pluralize.underscore.intern).find_every_without_site(*args)
    # end

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