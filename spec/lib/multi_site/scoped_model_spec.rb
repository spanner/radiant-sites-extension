require File.dirname(__FILE__) + "/../../spec_helper"

describe 'extended AR::Base' do
  it "should respond to is_site_scoped" do
    ActiveRecord::Base.respond_to?(:is_site_scoped).should be_true
  end
end

unless Snippet.column_names.include?('site_id')
  Snippet.connection.execute("ALTER TABLE snippets ADD site_id INT")    # dirty dirty dirty!
  Snippet.reset_column_information
end

describe "Site-scoped, unshareable Snippet", :type => :model do
  dataset :sites
  
  Snippet.send :is_site_scoped
  
  before do
    Page.current_site = sites(:mysite)
  end
  
  it "should report itself site_scoped" do
    Snippet.is_site_scoped?.should be_true
  end

  it "should have a site association" do
    Snippet.reflect_on_association(:site).should_not be_nil
  end

  it "should respond to current_site" do
    Snippet.respond_to?(:current_site).should be_true
  end

  it "should not respond to current_site=" do
    Snippet.respond_to?(:current_site=).should be_false
  end

  it "should return the corrent current site" do
    Snippet.send(:current_site).should == sites(:mysite)
  end
  
  describe "when instantiated" do
    before do
      @in_my_site = Snippet.new(:name => 'test snippet in mysite')
    end
  
    it "should not necessarily have a site" do
      @in_my_site.site.should be_nil
    end

    it "should accept a site" do
      @in_my_site.site = sites(:mysite)
      @in_my_site.site.should == sites(:mysite)
    end
  end

  describe "when validated" do
    before do
      @in_my_site = Snippet.new(:name => 'test snippet in mysite')
      @in_my_site.valid?
    end
    
    it "should have been given the current site" do
      @in_my_site.site.should_not be_nil
      @in_my_site.site.should == sites(:mysite)
    end
    
    describe "with site-scope" do
      before do
        Page.current_site = sites(:mysite)
        Snippet.create!(:name => 'testy')
      end
      it "should be invalid if its name is already in use on this site" do
        snippet = Snippet.new(:name => 'testy')
        snippet.valid?.should_not be_true
        snippet.errors.should_not be_nil
        snippet.errors.on(:name).should_not be_nil
      end

      it "should be valid even though its name is already in use on another site" do
        Page.current_site = sites(:yoursite)
        snippet = Snippet.new(:name => 'testy')
        snippet.valid?.should be_true
      end
    end
  end 
  
  describe "when no site is specified" do
    before do
      Page.current_site = nil
    end

    it "should raise a SiteNotFound error" do
      lambda {@in_my_site = Snippet.create!(:name => 'test snippet in mysite')}.should raise_error(MultiSite::SiteNotFound)
    end
  end
  
  describe "on retrieval" do
    before do
      20.times { |i| Snippet.create!(:name => "snippet#{i}") }
      @mysnippetid = Snippet.find_by_name('snippet10').id
      Page.current_site = sites(:yoursite)
      20.times { |i| Snippet.create!(:name => "snippet#{i+20}") }
      @yoursnippetid = Snippet.find_by_name('snippet30').id
      Page.current_site = sites(:mysite)
    end
    
    it "should find a snippet from the current site" do
      lambda {@snippet = Snippet.find(@mysnippetid)}.should_not raise_error(ActiveRecord::RecordNotFound)
      @snippet.should_not be_nil
      @snippet.site.should == sites(:mysite)
    end

    it "should find_by_name a snippet from the current site" do
      lambda {@snippet = Snippet.find_by_name('snippet10')}.should_not raise_error(ActiveRecord::RecordNotFound)
      @snippet.should_not be_nil
      @snippet.site.should == sites(:mysite)
    end

    it "should not find a snippet from another site" do
      lambda {@snippet = Snippet.find(@yoursnippetid)}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not find_by_name a snippet from another site" do
      @snippet = Snippet.find_by_name('snippet30').should be_nil
    end

    it "should count only the snippets from this site" do
      Snippet.count(:all).should == 20
    end

    describe "when no site is specified" do
      before do
        Page.current_site = nil
      end

      it "should raise a SiteNotFound error for a snippet that exists" do
        lambda {@snippet = Snippet.find(@yoursnippetid)}.should raise_error(MultiSite::SiteNotFound)
      end

      it "should raise a SiteNotFound error for a nonexistent snippet" do
        lambda {@snippet = Snippet.find('fish')}.should raise_error(MultiSite::SiteNotFound)
      end
    end  
  end
end


unless User.column_names.include?('site_id')
  User.connection.execute("ALTER TABLE users ADD site_id INT")    # oh, eric. he's doing it again.
  User.reset_column_information
end

describe "Site-scoped, shareable User", :type => :model do
  User.send :is_site_scoped, :shareable => true
  dataset :sites
  dataset :site_users

  before do
    Page.current_site = sites(:mysite)
  end

  describe "on instantiation with no site" do
    before do      
      @user = User.new(:name => 'test user', :login => 'test', :password => 'password', :email => 'test@spanner.org', :password_confirmation => 'password' )
    end
    
    it "should validate without being given the current site" do
      @user.valid?.should be_true
      @user.site.should be_nil
    end
  end 

  describe "on retrieval" do
    
    it "should find a user from the current site" do
      lambda {User.find(user_id(:myuser))}.should_not raise_error(ActiveRecord::RecordNotFound)
    end

    it "should find_by_name a user from the current site" do
      User.find_by_name('myuser').should_not be_nil
    end

    it "should not find a user from another site" do
      lambda {User.find(user_id(:youruser))}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not find_by_name a user from another site" do
      User.find_by_name('youruser').should be_nil
    end

    it "should find a user with no site" do
      lambda {User.find(user_id(:shareduser))}.should_not raise_error(ActiveRecord::RecordNotFound)
    end

    it "should find_by_name a user with no site" do
      User.find_by_name('shareduser').should_not be_nil
    end

    it "should count the users from this site or with no site" do
      # core radiant users_dataset creates 5 users with no site. Site_users_dataset creates 2 with this site and 2 with none
      User.count(:all).should == 9  
    end

  end
  
  
  
end
