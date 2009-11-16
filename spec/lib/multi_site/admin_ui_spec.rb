require File.dirname(__FILE__) + "/../../spec_helper"

describe "AdminUI extensions for multi_site" do
  before :each do
    @admin = Radiant::AdminUI.new
    @admin.site = Radiant::AdminUI.load_default_site_regions
  end

  it "should be included into Radiant::AdminUI" do
    Radiant::AdminUI.included_modules.should include(Sites::AdminUI)
  end

  it "should define a collection of Region Sets for sites" do
    @admin.should respond_to('site')
    @admin.should respond_to('sites')
    @admin.send('site').should_not be_nil
    @admin.send('site').should be_kind_of(OpenStruct)
  end

  describe "should define default regions" do
    %w{new edit remove index}.each do |action|
      
      describe "for '#{action}'" do
        before do
          @site = @admin.site
          @site.send(action).should_not be_nil
        end
              
        it "as a RegionSet" do
          @site.send(action).should be_kind_of(Radiant::AdminUI::RegionSet)
        end
      end
    end
  end
end
