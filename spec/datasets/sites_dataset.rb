class SitesDataset < Dataset::Base
  uses :site_pages
  
  def load
    create_record Site, :mysite, :name => 'My Site', :domain => 'mysite.domain.com', :base_domain => 'mysite.domain.com', :position => 1, :homepage_id => page_id(:myhomepage)
    create_record Site, :yoursite, :name => 'Your Site', :domain => '^yoursite', :base_domain => 'yoursite.test.com', :position => 2, :homepage_id => page_id(:yourhomepage)
    create_record Site, :default, :name => 'Default', :base_domain => 'digitalpulp\.com', :position => 3, :homepage_id => page_id(:home)
    create_record Site, :testing, :name => 'Test host', :domain => '^test\.', :base_domain => 'test.host', :position => 6
  end
end
