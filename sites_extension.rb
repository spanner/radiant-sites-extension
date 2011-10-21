require_dependency 'application_controller'

class SitesExtension < Radiant::Extension
  version RadiantSitesExtension::VERSION
  description RadiantSitesExtension::DESCRIPTION
  url RadiantSitesExtension::URL

  def activate
    # ScopedValidation is a nasty hack that doesn't want to reload.
    require 'sites/scoped_validation'

    # Model extensions
    ActiveRecord::Base.send :include, Sites::SiteScopedModel
    Page.send :include, Sites::PageExtensions

    # Controller extensions
    ApplicationController.send :include, Sites::ApplicationControllerExtensions
    SiteController.send :include, Sites::SiteControllerExtensions
    Admin::ResourceController.send :include, Sites::ResourceControllerExtensions
    Admin::PagesController.send :include, Sites::PagesControllerExtensions

    Layout.send :has_site
    Snippet.send :has_site
    User.send :has_many_sites

    unless defined? admin.site
      Radiant::AdminUI.send :include, Sites::AdminUI 
      admin.site = Radiant::AdminUI.load_default_site_regions
    end

    if respond_to?(:tab)
      tab("Content") do
        add_item("Sites", "/admin/sites", :visibility => [:admin])
      end
    else
      admin.tabs.add "Sites", "/admin/sites", :visibility => [:admin]
    end
  end

  def deactivate
  end
end

class ActiveRecord::SiteNotFound < Exception; end

