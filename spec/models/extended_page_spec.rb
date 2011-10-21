require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  dataset :sites
  
  describe "#path" do
    before do
      Page.current_site = sites(:default)
      @page = pages(:defaulthomepage)
    end

    it "should alias default" do
      @page.should respond_to(:path_with_sites)
      @page.should respond_to(:path_without_sites)
    end
    
    it "should override slug" do
      @page.path.should eql('/')
      @page.slug = "some-slug"
      @page.path.should eql('/')
    end
  end

  describe ".find_by_path" do
    it "should find site-scoped pages" do
      Page.current_site = sites(:mysite)
      Page.find_by_path("/mypage").should == pages(:myotherpage)
    end

    it "should not find pages outside the site" do
      Page.current_site = sites(:mysite)
      Page.find_by_path("/yourotherpage").should be_nil
    end
  end
  
  describe "#destroy" do
    it "should nullify homepage_id" do
      sites(:mysite).homepage_id.should_not be_nil
      pages(:myhomepage).destroy
      sites(:mysite).reload.homepage_id.should be_nil
    end
  end

end