class PagesHaveSite < ActiveRecord::Migration
  def self.up
    add_column :pages, :site_id, :integer
    add_index :pages, :site_id

    Page.reset_column_information
    Page.all do |page|
      if site = page.ancestral_site
        page.update_attribute(:site_id, site.id)
      else
        puts "! Warning: page #{page.id} has no site"
      end
    end
  end

  def self.down
    remove_column :pages, :site_id
  end
end
