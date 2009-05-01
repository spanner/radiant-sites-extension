module MultiSite
  module ActionObserverExtensions

    def self.included(base)
      base.class_eval do

        def before_validation(model)
          if User.reflect_on_association(:site) && model.class.is_site_scoped?
            if self.class.current_user && self.class.current_user.site
              model.site_id = model.new_record? ? self.class.current_user.site.id : model.site_id_was          # site-bound user shouldn't change site association, and should create items bound to own site
            end
            model.site ||= Page.current_site unless model.class.is_shareable?                                  # unshareable model classes must be bound to something
          end
        end

      end
    end
  end
end
