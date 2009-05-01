class Site < ActiveRecord::Base
  acts_as_list
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  order_by "position ASC"

  class << self
    def find_for_host(hostname = '')
      # default, normal = find(:all).partition {|s| s.domain.blank? }
      # matching = normal.find do |site|
      #   hostname == site.base_domain || hostname =~ Regexp.compile(site.domain)
      # end
      # matching || default.first || catchall
      # 
      
      # the only real change here is that if we find no site, we create one with no domain
      # in most cases we save a query, though
      
      matches = find(:all, :conditions => "sites.domain IS NOT NULL AND sites.domain != ''").select{|site| hostname == site.base_domain || hostname =~ Regexp.compile(site.domain) }
      matches.any? ? matches.first : catchall
    end
    
    def catchall
      find_by_domain('') || find_by_domain(nil) || create({
        :domain => '', 
        :name => 'default_site', 
        :base_domain => 'localhost',
        :homepage => Page.find_by_parent_id(nil)
      })
    end
    
    def several?
      count > 1
    end
  end
  
  belongs_to :homepage, :class_name => "Page", :foreign_key => "homepage_id"
  validates_presence_of :name, :base_domain
  validates_uniqueness_of :domain
  
  after_create :create_homepage
  after_save :reload_routes
  
  def url(path = "/")
    uri = URI.join("http://#{self.base_domain}", path)
    uri.to_s
  end
    
  def dev_url(path = "/")
    uri = URI.join("http://#{Radiant::Config['dev.host']|| 'dev'}.#{self.base_domain}", path)
    uri.to_s
  end
  
  def create_homepage
    if self.homepage_id.blank?
        self.homepage = self.build_homepage(:title => "#{self.name} Homepage", 
                           :slug => "#{self.name.to_slug}", :breadcrumb => "Home", 
                           :status => Status[:draft])
        self.homepage.parts << PagePart.new(:name => "body", :content => "")
        save
    end
  end
  
  def reload_routes
    ActionController::Routing::Routes.reload
  end
end
