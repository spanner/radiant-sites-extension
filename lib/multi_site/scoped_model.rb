module MultiSite
  
  module ScopedModel
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      def is_site_scoped?
        false
      end
      
      # only option at the moment is :shareable, which we take to mean that sites are optional:
      # if true it causes us not to set the site automatically or validate its presence
      # and to extend the scoping conditions so that objects with no site are returned as 
      # well as objects with the specified site
      # that is, anything without a site is considered to be shared among all of them
      # the default is false
      
      def is_site_scoped(options={})
        return if is_site_scoped?
        
        options = {
          :shareable => false
        }.merge(options)

        class_eval <<-EO
          extend MultiSite::ScopedModel::ScopedClassMethods
          include MultiSite::ScopedModel::ScopedInstanceMethods
        EO
        
        belongs_to :site
        Site.send(:has_many, plural_symbol_for_class)

        before_validation :set_site unless options[:shareable]
        validates_presence_of :site unless options[:shareable]

        class << self
          attr_accessor :shareable
          alias_method_chain :find_every, :site
          %w{count average minimum maximum sum}.each do |getter|
            alias_method_chain getter.intern, :site
          end
        end
        
        self.shareable = options[:shareable]
      end
    end

    module ScopedClassMethods
      def find_every_with_site(options)
        # logger.warn ">>> #{self}.find_every_with_site(#{options.inspect})"
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
        raise(ActiveRecord::SiteNotFound, "no site found", caller) unless current_site && current_site.is_a?(Site)
        current_site
      end

      def current_site
        Page.current_site
      end
            
      def site_scope_condition
        self.shareable ? "#{table_name}.site_id = #{current_site!.id} OR #{table_name}.site_id IS NULL" : "#{table_name}.site_id = #{current_site!.id}"
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

