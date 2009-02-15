class AddOwnerInformation < ActiveRecord::Migration
  def self.up
    add_column :sites, :mail_from_name, :string
    add_column :sites, :mail_from_address, :string
    Radiant
  end
  
  def self.down
    remove_column :sites, :mail_from_name
    remove_column :sites, :mail_from_address
  end
end
