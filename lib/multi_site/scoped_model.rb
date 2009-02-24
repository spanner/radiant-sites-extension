module MultiSite
  class SiteNotFound < Exception; end
  
  module ScopedModel
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      def is_site_scoped?
        false
      end
      
      def is_site_scoped(options={})
        return if is_site_scoped?
        
        options = {
          :site_required => true,
          :site_validated => false,
          :site_populated => true,
          :site_associated => true
        }.merge(options)
        
        class_eval do
          extend MultiSite::ScopedModel::ScopedClassMethods
          include MultiSite::ScopedModel::ScopedInstanceMethods
        end
        
        belongs_to :site
        before_validation :set_site if options[:site_populated]
        validates_presence_of :site if options[:site_required]
        validates_associated :site if options[:site_validated]
        Site.send(:has_many, plural_symbol_for_class) if options[:site_associated]

        class << self
          alias_method_chain :find_every, :site
          %w{count average minimum maximum sum}.each do |getter|
            alias_method_chain getter.intern, :site
          end
        end
      end
    end

    module ScopedClassMethods
      def find_every_with_site(options)
        with_scope(:find => {:conditions => site_scope_condition}) do
          find_every_without_site(options)
        end
      end

      %w{count average minimum maximum sum}.each do |getter|
        define_method("#{getter}_with_site") do |*args|
          with_scope(:find => {:conditions => site_scope_condition}) do
            send "#{getter}_without_site".intern, *args
          end
        end
      end

      def current_site!
        raise(MultiSite::SiteNotFound, "no site found", caller) unless current_site && current_site.is_a?(Site)
        current_site
      end

      def current_site
        Page.current_site
      end

      def site_scope_condition
        "site_id = #{current_site!.id}"
      end
    
      def plural_symbol_for_class
        self.to_s.pluralize.underscore.intern
      end
      
      def is_site_scoped?
        true
      end

    end
  
    module ScopedInstanceMethods
      protected
        def set_site
          self.site ||= self.class.current_site!
        end
    end
  end
end

