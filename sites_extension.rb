require_dependency 'application_controller'

class SitesExtension < Radiant::Extension
  version "1.0"
  description %{ Virtual sites with templates, scoping framework, import-export, friendly admin and userland site- (and account-) creation tools. Far from complete.}
  url "http://spanner.org/radiant/sites"

  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :sites
    end    
  end

  def activate
    # ActionController::Routing modules are required rather than sent as includes
    # because the routing persists between dev. requests and is not compatible
    # with multiple alias_method_chain calls.
    require 'sites/route_extensions'
    require 'sites/route_set_extensions'
    
    # likewise for ScopedValidation, which is a pre-emptive hack that shouldn't run more than once.
    require 'sites/scoped_validation'

    # Model extensions
    ActiveRecord::Base.send :include, Sites::ScopedModel
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

