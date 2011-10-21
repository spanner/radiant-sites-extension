class SitesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_site "mysite", :name => 'My Site', :domain => 'mysite.domain.com', :base_domain => 'mysite.domain.com', :position => 1 do
      create_site_page "Myhomepage", :body => 'This is my page', :slug => '/' do
        create_site_page "Myotherpage", :body => 'This is my other page', :slug => 'mypage'
      end
      set_site_home :mysite, :myhomepage
    end

    create_site "yoursite", :name => 'Your Site', :domain => '^yoursite', :base_domain => 'yoursite.test.com', :position => 2 do
      create_site_page "Yourhomepage", :body => 'This is your home page', :slug => '/' do
        create_site_page "Yourotherpage", :body => 'This is your other page', :slug => 'yourpage'
      end
      set_site_home :yoursite, :yourhomepage
    end
    
    create_site "default", :name => 'Default', :base_domain => 'domain.com', :position => 3, :homepage_id => page_id(:home) do
      create_site_page "Defaulthomepage", :body => 'This is the default home page', :slug => '/'
    end

    create_site "testing", :name => 'Test host', :domain => '^test\.', :base_domain => 'test.host', :position => 6
  end

  helpers do
    def create_site(name, attributes={})
      symbol = name.symbolize
      create_record :site, symbol, attributes.merge(:name => name)
      if block_given?
        current_site = Page.current_site
        Page.current_site = sites(symbol)
        yield
        Page.current_site = current_site
      end
    end

    def create_site_page(name, attributes={}, &block)
      create_page(name, attributes.merge(:site_id => Page.current_site.id), &block)
    end
    
    def set_site_home(site, page)
      site = sites(site) unless site.is_a? Site
      page = pages(page) unless page.is_a? Page
      site.homepage_id = page.id
      site.save
    end
  end

end


