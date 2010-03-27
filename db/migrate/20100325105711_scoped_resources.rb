class ScopedResources < ActiveRecord::Migration
  def self.up
    [:layouts, :snippets].each do |table|
      add_column table, :site_id, :integer
      klass = table.to_s.classify.constantize
      klass.reset_column_information
      klass.find_without_site(:all, :conditions => 'site_id IS NULL').each do |thing| 
        thing.update_attribute(:site_id, Site.default)
      end
    end
    create_table :sites_users do |t|
      t.column :site_id, :integer
      t.column :user_id, :integer
      t.column :admin, :boolean
      t.column :designer, :boolean
    end
  end

  def self.down
    drop_table :sites_users
    [:layouts, :snippets].each do |table|
      remove_column table, :site_id
    end
  end
end
