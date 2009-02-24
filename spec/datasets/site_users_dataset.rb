class SiteUsersDataset < Dataset::Base
  uses :users, :sites
  
  def load
    create_user "myuser", :site => sites(:mysite)
    create_user "youruser", :site => sites(:yoursite)
    create_user "shareduser", :admin => true
    create_user "myadmin", :site => sites(:mysite), :admin => true
    create_user "youradmin", :site => sites(:yoursite), :admin => true
    create_user "sharedadmin", :admin => true
  end

end
