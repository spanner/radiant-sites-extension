class SitePagesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "Myhomepage", :body => 'This is my page', :slug => '/' do
      create_page "Myotherpage", :body => 'This is my other page', :slug => 'mypage'
    end
    create_page "Yourhomepage", :body => 'This is your home page', :slug => '/' do
      create_page "Yourotherpage", :body => 'This is your other page', :slug => 'yourpage'
    end
  end
  
end