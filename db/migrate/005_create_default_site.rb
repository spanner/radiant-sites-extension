class CreateDefaultSite < ActiveRecord::Migration
  def self.up
    Site.reset_column_information
    unless Site.find_by_domain(nil)
      Site.create!({
        :name => "default site",
        :subtitle => 'created automatically',
        :domain => "",
        :base_domain => 'localhost',
        :created_by => User.find_by_admin(1),
        :homepage => Page.find_by_parent_id(nil)
      })
    end
  end
  
  def self.down

  end
end
