require File.dirname(__FILE__) + "/../../spec_helper"

class StubController < ActionController::Base
  include MultiSite::ControllerExtensions
  def show; end
  def rescue_action(e) raise e end
  def method_missing(method, *args, &block)
    if (args.size == 0) and not block_given?
     render :text => 'just a test' unless @performed_render || @performed_redirect
    else
      super
    end
  end
end

describe 'Multisite extended controller', :type => :controller do
  controller_name "stub"
  dataset :sites

  before do
    map = ActionController::Routing::RouteSet::Mapper.new(ActionController::Routing::Routes)
    map.connect ':controller/:action/:id'
    ActionController::Routing::Routes.named_routes.install
  end

  after do
    ActionController::Routing::Routes.reload
  end

  describe "with a request that matches a site" do
    before do
      @site = sites(:testing)
      get :show
    end
    
    it "should respond correctly to current_site" do
      controller.send(:current_site).should == @site
    end
    
    it "should set Page.current_site" do
      Page.current_site.should == @site
    end

  end
  
  describe "with a request that matches no site" do
    before do
      @host = 'nosite.domain.com'
      @site = sites(:default)
      @cookies = {}
      controller.request.stub!(:host).and_return(@host)
      controller.stub!(:cookies).and_return(@cookies)
    end
    
    it "should choose the default site" do
      controller.send(:current_site).should == @site
    end
  end 
end