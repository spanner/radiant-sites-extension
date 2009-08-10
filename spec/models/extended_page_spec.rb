require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  dataset :sites
  
  before do
    @page = pages(:home)
  end
  
  describe "#url" do
    it "should alias default" do
      @page.should respond_to(:url_with_sites)
      @page.should respond_to(:url_without_sites)
    end
    
    it "should override slug" do
      @page.url.should eql('/')
      @page.slug = "some-slug"
      @page.url.should eql('/')
    end
  end

  describe ".find_by_url" do
    it "should default to the catchall site" do
      Page.current_site = nil
      Page.find_by_url("/").should == pages(:home)
    end
    
    it "should find site-scoped pages" do
      Page.current_site = sites(:mysite)
      Page.find_by_url("/mypage").should == pages(:myotherpage)
    end

    it "should not find pages outside the site" do
      Page.current_site = sites(:mysite)
      Page.find_by_url("/yourotherpage").should be_nil
    end
  end
  
  describe "#destroy" do
    it "should nullify homepage_id" do
      sites(:mysite).homepage_id.should_not be_nil
      pages(:home).destroy
      sites(:mysite).reload.homepage_id.should be_nil
    end
  end

end