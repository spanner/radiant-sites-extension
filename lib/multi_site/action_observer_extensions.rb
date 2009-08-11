module MultiSite
  module ActionObserverExtensions

    def self.included(base)
      base.class_eval do

        def before_validation(model)
          if model.class.is_site_scoped? && !model.class.is_shareable?
            model.site ||= Page.current_site
          end
        end

      end
    end
  end
end
