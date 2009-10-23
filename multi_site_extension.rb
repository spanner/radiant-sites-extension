require_dependency 'application_controller'

class MultiSiteExtension < Radiant::Extension
  version "0.8.1"
  description %{ Enables virtual sites to be created with associated domain names.
                 Also scopes the sitemap view to any given page (or the root of an
                 individual site) and allows model classes to be scoped by site. }
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

  extension_config do |config|
    config.extension 'submenu'
  end

  def activate
    # ActionController::Routing modules are required rather than sent as includes
    # because the routing persists between dev. requests and is not compatible
    # with multiple alias_method_chain calls.
    require 'multi_site/route_extensions'
    require 'multi_site/route_set_extensions'
    
    # likewise for ScopedValidation, which is a pre-emptive hack that shouldn't run more than once.
    require 'multi_site/scoped_validation'

    # Model extensions
    ActiveRecord::Base.send :include, MultiSite::ScopedModel
    Page.send :include, MultiSite::PageExtensions

    # Controller extensions
    ApplicationController.send :include, MultiSite::ApplicationControllerExtensions
    SiteController.send :include, MultiSite::SiteControllerExtensions
    Admin::ResourceController.send :include, MultiSite::ResourceControllerExtensions
    Admin::PagesController.send :include, MultiSite::PagesControllerExtensions
    UserActionObserver.send :include, MultiSite::ActionObserverExtensions

    unless defined? admin.site
      Radiant::AdminUI.send :include, MultiSite::AdminUI 
      admin.site = Radiant::AdminUI.load_default_site_regions
    end

    admin.tabs.add "Sites", "/admin/sites", :visibility => [:admin]

  end

  def deactivate
  end
end

class ActiveRecord::SiteNotFound < Exception; end

