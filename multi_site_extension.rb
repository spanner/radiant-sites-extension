require_dependency 'application'

class MultiSiteExtension < Radiant::Extension
  version "0.4"
  description %{ Enables virtual sites to be created with associated domain names.
                 Also scopes the sitemap view to any given page (or the root of an
                 individual site) and allows model classes to be scoped. }
  url "http://radiantcms.org/"

  define_routes do |map|
      map.resources :sites, :path_prefix => "/admin",
                  :member => {
                    :move_higher => :post,
                    :move_lower => :post,
                    :move_to_top => :put,
                    :move_to_bottom => :put
                  }
  end

  def activate
    # Model extensions
    ActiveRecord::Base.send :include, MultiSite::ScopedModel
    ActiveRecord::Validations::ClassMethods.send :include, MultiSite::ScopedValidation
    Page.send :include, MultiSite::PageExtensions
    ResponseCache.send :include, MultiSite::ResponseCacheExtensions

    # Controller extensions
    ApplicationController.send :include, MultiSite::ControllerExtensions
    SiteController.send :include, MultiSite::SiteControllerExtensions
    Admin::ResourceController.send :include, MultiSite::ResourceControllerExtensions
    Admin::PagesController.send :include, MultiSite::PagesControllerExtensions
    UserActionObserver.send :include, MultiSite::ActionObserverExtensions

    # AdminUI extensions
    Radiant::AdminUI.send :include, MultiSite::AdminUI unless defined? admin.site # UI is a singleton and already loaded
    admin.site = Radiant::AdminUI.load_default_site_regions

    Radiant::Config["dev.host"] = 'preview' if Radiant::Config.table_exists?

    admin.pages.index.add :top, "admin/shared/site_jumper"
  end

  def deactivate
  end
end

class ActiveRecord::SiteNotFound < Exception; end

