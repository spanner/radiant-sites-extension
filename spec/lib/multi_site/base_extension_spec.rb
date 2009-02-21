require File.dirname(__FILE__) + "/../../spec_helper"

# class StubModel < ActiveRecord::Base
#   self.abstract_class = true
# 
#   def self.columns
#     @columns ||= [];
#   end
# 
#   def self.column(name, sql_type = nil, default = nil, null = true)
#     columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
#   end
# 
#   def save(validate = true)
#     validate ? valid? : true
#   end
# end
# 
# class TestModel < StubModel
#   column :name, :string  
#   column :site_id, :string  
#   is_site_scoped
# end

describe 'extended AR::Base' do

  it "should respond to is_site_scoped" do
    ActiveRecord::Base.respond_to?(:is_site_scoped).should be_true
  end

end