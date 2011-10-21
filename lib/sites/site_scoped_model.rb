module Sites
  
  module SiteScopedModel
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      def has_site?
        false
      end
      alias :is_site_scoped? :has_site?

      def can_have_sites?
        false
      end

      def has_sites?
        false
      end
      
      def plural_symbol_for_class
        self.to_s.pluralize.underscore.intern
      end
      
      def has_site(old_args={})
        return if has_site?
        return has_many_sites if(old_args[:shareable])

        class_eval <<-EO
          extend Sites::SiteScopedModel::ScopedClassMethods
          include Sites::SiteScopedModel::ScopedInstanceMethods
        EO
        
        belongs_to :site
        Site.send(:has_many, plural_symbol_for_class, :dependent => :destroy)

        before_validation :set_site
        validates_presence_of :site

        class << self
          alias_method_chain :find_every, :site
          %w{count average minimum maximum sum}.each do |getter|
            alias_method_chain getter.intern, :site
          end
        end
      end
      alias :is_site_scoped :has_site
      
      def has_many_sites
        return if can_have_sites?

        class_eval <<-EO
          extend Sites::SiteScopedModel::LinkedClassMethods
          include Sites::SiteScopedModel::LinkedInstanceMethods
        EO

        has_and_belongs_to_many :sites
        Site.send(:has_and_belongs_to_many, plural_symbol_for_class)
      end
    end

    module ScopedClassMethods
      def find_every_with_site(options)
        return find_every_without_site(options) unless sites?
        with_scope(:find => {:conditions => site_scope_condition}) do
          find_every_without_site(options)
        end
      end

      %w{count average minimum maximum sum}.each do |getter|
        define_method("#{getter}_with_site") do |*args|
          return send("#{getter}_without_site".intern, *args) unless sites?
          with_scope(:find => {:conditions => site_scope_condition}) do
            send "#{getter}_without_site".intern, *args
          end
        end
      end
      
      # this only works with :all and :first
      # and only meant for use in special cases like migration.
      
      def find_without_site(*args)
        options = args.extract_options!
        validate_find_options(options)
        set_readonly_option!(options)

        case args.first
          when :first then find_initial_without_site(options)     # defined here
          when :all   then find_every_without_site(options)       # already defined by the alias chain
        end
      end
      
      def find_initial_without_site(options)
        options.update(:limit => 1)
        find_every_without_site(options).first
      end
      
      def sites?
        Site.table_exists? && Site.several?
      end

      def current_site!
        raise(ActiveRecord::SiteNotFound, "#{self} is site-scoped but current_site is #{self.current_site.inspect}", caller) if sites? && !self.current_site
        Page.current_site
      end

      def current_site
        Page.current_site
      end
            
      def site_scope_condition
        "#{self.table_name}.site_id = #{self.current_site!.id}"
      end
          
      def has_site?
        true
      end
    end
  
    module ScopedInstanceMethods
      protected
        def set_site
          self.site ||= self.class.current_site!
        end
    end
    
    module LinkedClassMethods
      def can_have_sites?
        true
      end
    end
    module LinkedInstanceMethods
      def has_many_sites?
        sites.count > 1
      end
      
      def has_one_site?
        sites.count == 1
      end
    end
    
  end
end

