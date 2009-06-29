require File.dirname(__FILE__) + "/../../spec_helper"

describe 'extended AR::Base' do
  it "should respond to is_site_scoped" do
    ActiveRecord::Base.respond_to?(:is_site_scoped).should be_true
  end
end

describe "scoped, unshareable model", :type => :model do
  dataset :sites
  dataset :users
  
  before do
    Page.stub!(:current_site).and_return(sites(:mysite))
    UserActionObserver.stub!(:current_user).and_return(users(:admin))
    Snippet.stub!(:site_id).and_return(site_id(:mysite))
    Snippet.send :is_site_scoped
  end
  
  it "should report itself site_scoped" do
    Snippet.is_site_scoped?.should be_true
  end

  it "should not report itself shareable" do
    Snippet.is_shareable?.should_not be_true
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

  it "should return the correct current site" do
    Snippet.send(:current_site).should == sites(:mysite)
  end
  
  describe "when instantiated" do
    before do
      @in_my_site = Snippet.new(:name => 'test snippet in mysite')
    end
  
    it "should not yet have a site" do
      @in_my_site.site.should be_nil
    end

    it "should accept a site" do
      @in_my_site.site = sites(:mysite)
      @in_my_site.site.should == sites(:mysite)
    end
  end

  describe "when validated" do
    before do
      @in_my_site = Snippet.new(:name => 'test_snippet_in_mysite')
      @in_my_site.valid?
    end
    
    it "should have been given the current site" do
      @in_my_site.site.should_not be_nil
      @in_my_site.site.should == sites(:mysite)
    end
    
    describe "with site-scope" do
      before do
        @existing = Snippet.create!(:name => 'testy', :site_id => site_id(:mysite))
      end
      it "should be invalid if its name is already in use on this site" do
        snippet = Snippet.new(:name => 'testy')
        snippet.valid?.should_not be_true
        snippet.errors.should_not be_nil
        snippet.errors.on(:name).should_not be_nil
      end

      it "should be valid even though its name is already in use on another site" do
        snippet = Snippet.new(:name => 'testy', :site_id => site_id(:yoursite) )
        snippet.valid?.should be_true
      end
    end
  end 
  
  describe "on retrieval" do
    before do
      20.times { |i| @mine = Snippet.create!(:name => "snippet#{i}", :site_id => site_id(:mysite)) }
      20.times { |i| @yours = Snippet.create!(:name => "snippet#{i+20}", :site_id => site_id(:yoursite)) }
    end
    
    it "should find a snippet from the current site" do
      lambda {@snippet = Snippet.find(@mine.id)}.should_not raise_error(ActiveRecord::RecordNotFound)
      @snippet.should_not be_nil
      @snippet.site.should == sites(:mysite)
    end

    it "should find_by_name a snippet from the current site" do
      lambda {@snippet = Snippet.find_by_name('snippet10')}.should_not raise_error(ActiveRecord::RecordNotFound)
      @snippet.should_not be_nil
      @snippet.site.should == sites(:mysite)
    end

    it "should not find a snippet from another site" do
      lambda {@snippet = Snippet.find(@yours.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not find_by_name a snippet from another site" do
      @snippet = Snippet.find_by_name('snippet30').should be_nil
    end

    it "should count only the snippets from this site" do
      Snippet.count(:all).should == 20
    end

  end
end



describe "scoped, shareable model", :type => :model do
  dataset :sites
  dataset :users

  before do
    User.stub!(:site_id).and_return(site_id(:mysite))
    User.send :is_site_scoped, :shareable => true
    Page.current_site = sites(:mysite)
  end

  describe "on instantiation with no site" do
    before do      
      @user = User.new(:name => 'test user', :login => 'test', :password => 'password', :email => 'test@spanner.org', :password_confirmation => 'password' )
      @otheruser = User.new(:name => 'other user', :site => sites(:yoursite), :login => 'other', :password => 'password', :email => 'other@spanner.org', :password_confirmation => 'password' )
    end
    
    it "should validate without a site" do
      @user.valid?.should be_true
      @user.site.should be_nil
    end

    it "should validate with a site" do
      @otheruser.valid?.should be_true
      @otheruser.site.should_not be_nil
    end
  end 

  describe "on retrieval" do
    before do      
      @user = User.create(:name => 'shared user', :login => 'shared', :password => 'password', :email => 'test@spanner.org', :password_confirmation => 'password' )
      @localuser = User.create(:name => 'local user', :site => sites(:mysite), :login => 'ocal', :password => 'password', :email => 'local@spanner.org', :password_confirmation => 'password' )
      @otheruser = User.create(:name => 'other user', :site => sites(:yoursite), :login => 'other', :password => 'password', :email => 'other@spanner.org', :password_confirmation => 'password' )
    end

    it "should find a user with no site" do
      lambda {User.find(@user.id)}.should_not raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should find a user from the current site" do
      lambda {User.find(@localuser.id)}.should_not raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not find a user from another site" do
      lambda {User.find(@otheruser.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should count the users from this site or with no site" do
      # users_dataset creates 5 users with no site. we just made one shared and one local: total 7
      User.count(:all).should == 7
    end
  end
  
  
  
end
