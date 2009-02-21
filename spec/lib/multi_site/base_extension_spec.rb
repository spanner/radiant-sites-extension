require File.dirname(__FILE__) + "/../../spec_helper"

describe 'extended AR::Base' do

  it "should respond to is_site_scoped" do
    ActiveRecord::Base.respond_to?(:is_site_scoped).should be_true
  end

end