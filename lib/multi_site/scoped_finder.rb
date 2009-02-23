module MultiSite::ScopedFinder

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      belongs_to :site
      validates_presence_of :site, :message => 'not found'      # ought to be redundant
      before_validation :set_site
    end

    Site.send(:has_many, base.plural_symbol_for_class)

    # all (?) find operations, including attribute-based finders, end up calling find_every
    # so we extend that rather than trying to guess all the variations

    class << base
      # all (?) find operations, including attribute-based finders, end up calling find_every
      # by putting the main scoping operation here, we get everything.
      alias_method_chain :find_every, :site
      
      # but calculations all tend to be free-standing. we have to get those separately
      %w{count average minimum maximum sum}.each do |getter|
        alias_method_chain getter.intern, :site
      end
    end

    def set_site
      self.site ||= self.class.current_site!
    end
    
  end
  
  module ClassMethods

    # these are all the same. they turn eg. Reader.count(:all) into current_site.readers.count(:all)
    # but for present tinkering it's nice to separate the groups
    
    def find_every_with_site(*options)
      with_scope(:find => {:conditions => scope_condition}) do
        send :find_every_without_site, *options
      end
    end
    
    %w{count average minimum maximum sum}.each do |getter|
      define_method("#{getter}_with_site") do |*args|
        with_scope(:find => {:conditions => scope_condition}) do
          send "#{getter}_without_site".intern, *args
        end
      end
    end

    # override this if eg you want to return both site-specific and shared resources
    # in that case you'd want something like "users.site_id = #{current_site!.id} OR shared = 1"

    def scope_condition
      "site_id = #{current_site!.id}"
    end
    
    def plural_symbol_for_class
      self.to_s.pluralize.underscore.intern
    end
    
    def current_site!
      raise(MultiSite::SiteNotFound, "no site found", caller) unless current_site && current_site.is_a?(Site)
      current_site
    end
    
    def current_site
      Page.current_site
    end
    
  end
end

module MultiSite
  class SiteNotFound < Exception; end
end