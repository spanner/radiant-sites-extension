require_dependency 'application'

class MultiSiteExtension < Radiant::Extension
  version "0.8.1"
  description %{ Enables virtual sites to be created with associated domain names.
                 Also scopes the sitemap view to any given page (or the root of an
                 individual site) and allows model classes to be scoped. }
  url "http://radiantcms.org/"

  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :sites, :member => {
        :move_higher => :post,
        :move_lower => :post,
        :move_to_top => :put,
        :move_to_bottom => :put
      }
    end
  end


  def activate
    require 'multi_site/route_extensions'
    require 'multi_site/route_set_extensions'

    # Model extensions
    ActiveRecord::Base.send :include, MultiSite::ScopedModel
    ActiveRecord::Validations::ClassMethods.send :include, MultiSite::ScopedValidation

    Page.send :include, MultiSite::PageExtensions

    # Controller extensions
    ApplicationController.send :include, MultiSite::ControllerExtensions
    SiteController.send :include, MultiSite::SiteControllerExtensions
    Admin::ResourceController.send :include, MultiSite::ResourceControllerExtensions
    Admin::PagesController.send :include, MultiSite::PagesControllerExtensions
    UserActionObserver.send :include, MultiSite::ActionObserverExtensions

    # AdminUI extensions
    Radiant::AdminUI.send :include, MultiSite::AdminUI unless defined? admin.site # UI is a singleton and already loaded
    admin.site = Radiant::AdminUI.load_default_site_regions

    admin.pages.index.add :top, "admin/shared/site_jumper"
  end

  def deactivate
  end
end

class ActiveRecord::SiteNotFound < Exception; end

