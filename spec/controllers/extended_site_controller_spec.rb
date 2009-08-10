require File.dirname(__FILE__) + "/../spec_helper"

describe SiteController do
  dataset :sites

  before do
    # I don't know why we're not getting the site routes
    # possibly because of the routing tests?
    # but without them, controller tests fail
    ActionController::Routing::Routes.draw do |map|
      map.connect '*url', :controller => 'site', :action => 'show_page'
    end
  end
  
  describe "with a request that matches no site" do
    before do
      Page.current_site = nil
      @host = 'nosite.domain.com'
      controller.request.stub!(:host).and_return(@host)
    end
    
    it "should have chosen the catchall site" do
      get :show_page, :url => '/'
      Page.current_site.should == sites(:default)
    end
  end 
  
  describe "with a request that matches a site" do
    before do
      Page.current_site = nil
      @host = 'yoursite.domain.com'
      controller.request.stub!(:host).and_return(@host)
    end
        
    it "should have chosen the matching site" do
      get :show_page, :url => '/yourpage'
      Page.current_site.should == sites(:yoursite)
    end
    
    it "should return a page from the present site" do
      get :show_page, :url => '/yourpage'
      response.should be_success
      response.body.should == "This is your other page body."
    end
    
    describe "but for a page from another site" do
      it "should return 404" do
        get :show_page, :url => '/mypage'
        response.should be_missing
      end
    end

    describe "but for a page that doesn't exist" do
      it "should still return 404" do
        get :show_page, :url => '/notanyonespage'
        response.should be_missing
      end
    end
  end
end