# The site class includes - in find_for_host - some key retrieval and creation logic that is called from ApplicationController to set the current site context. 
# Otherwise it's just another radiant data model.

class Site < ActiveRecord::Base
  acts_as_list
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  default_scope :order => 'position ASC'

  class << self
    attr_accessor :several
    
    # I've added one or two sql queries here for the sake of a separate default method
    
    def find_for_host(hostname = '')
      return default if hostname.blank?
      sites = find(:all, :conditions => "domain IS NOT NULL and domain != ''")
      site = sites.find { |site| hostname == site.base_domain || hostname =~ Regexp.compile(site.domain) }
      site || default
    end
    
    # Site.default returns the the first site it can find with an empty domain pattern.

    def default
      find_by_domain('') || find_by_domain(nil) || catchall
    end
    
    # If none is found, we are probably brand new, so a workable default site is created.
    
    def catchall
      create({
        :domain => '', 
        :name => 'default_site', 
        :base_domain => 'localhost',
        :homepage => Page.find_without_site(:first, :conditions => "parent_id IS NULL")
      })
    end
    
    # Returns true if more than one site is present. This is normally only used to make interface decisions, eg whether to show the site-chooser dropdown.
    
    def several?
      several = (count > 1) if several.nil?
    end
  end
  
  belongs_to :homepage, :class_name => "Page", :foreign_key => "homepage_id"
  validates_presence_of :name, :base_domain
  validates_uniqueness_of :domain
  
  # after_save :reload_routes
  
  # Returns the fully specified web address for the supplied path, or the root of this site if no path is given.
  
  def url(path = "/")
    uri = URI.join("http://#{self.base_domain}", path)
    uri.to_s
  end

  # Returns the fully specified web address for the development version of this site and the supplied path, or the root of this site if no path is given.
    
  def dev_url(path = "/")
    uri = URI.join("http://#{Radiant::Config['dev.host'] || 'dev'}.#{self.base_domain}", path)
    uri.to_s
  end
  
  # def reload_routes
  #   ActionController::Routing::Routes.reload
  # end
end
