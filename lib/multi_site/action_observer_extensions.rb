# The ActionObserverExtensions add a before_validation routine to all scoped classes. 

module MultiSite
  module ActionObserverExtensions

    def self.included(base)
      base.class_eval do

        # Scoped models are given a before_validation method that forces an association with the correct site. It follows these ruls:
        # * If the current_user is bound to a site, anything she creates is associated with that site
        # * If the current_user is bound to a site, she is not allowed to change site associations (this allows her to edit shared objects, until I find a way to make them only editable by unsited people, but not to change their shared status)
        # * If the current_user is not bound to a site and the model class is shareable, we leave it alone so as to respect user input
        # * If the current_user is not site-bound but the model class is not shareable, we associate it with the site currently in the foreground (ie, Page.current_site)
        
        def before_validation(model)
          if model.class.is_site_scoped?
            if User.reflect_on_association(:site) && self.class.current_user && self.class.current_user.site
              model.site_id = model.new_record? ? self.class.current_user.site.id : model.site_id_was          # site-bound user shouldn't change site association, and should create items bound to own site
            end
            model.site ||= Page.current_site unless model.class.is_shareable?                                  # unshareable model classes must be bound to something
          end
        end

      end
    end
  end
end
