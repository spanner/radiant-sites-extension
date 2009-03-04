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
    ActiveRecord::Base.send :include, MultiSite::ScopedModel
    ActiveRecord::Validations::ClassMethods.send :include, MultiSite::ScopedValidation
    ApplicationController.send :include, MultiSite::ControllerExtensions
    Radiant::AdminUI.send :include, MultiSite::AdminUI         # UI is a singleton and already loaded, and this doesn't get there in time. so:
    Radiant::AdminUI.instance.site = Radiant::AdminUI.load_default_site_regions
    Page.send :include, MultiSite::PageExtensions
    SiteController.send :include, MultiSite::SiteControllerExtensions
    Admin::PagesController.send :include, MultiSite::PagesControllerExtensions
    ResponseCache.send :include, MultiSite::ResponseCacheExtensions
    ApplicationHelper.send :include, MultiSite::HelperExtensions
    
    Radiant::Config["dev.host"] = 'preview' if Radiant::Config.table_exists?

    admin.pages.index.add :top, "site_subnav"     # only contains scripting: we've put the site chooser in the masthead by overriding the helper method @subtitle@

    # admin.tabs.add "Sites", "/admin/sites", :visibility => [:admin]
  end

  def deactivate
    # admin.tabs.remove "Sites"
  end
end
