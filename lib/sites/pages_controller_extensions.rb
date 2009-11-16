module Sites::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :discover_current_site, :root
      alias_method_chain :index, :site
      alias_method_chain :continue_url, :site
      alias_method_chain :remove, :back
      responses.destroy.default do 
        return_url = session[:came_from]
        session[:came_from] = nil
        redirect_to return_url || admin_pages_url(:root => model.root.id)
      end
    }
  end

  # for compatibility with the standard issue of multi_site, 
  # a root parameter overrides other ways of setting site

  def discover_current_site_with_root
    site_from_root || discover_current_site_without_root
  end

  def site_from_root
    if params[:root] && @homepage = Page.find(params[:root])
      @site = @homepage.root.site
    end
  end

  def index_with_site
    @site ||= Page.current_site
    @homepage ||= @site.homepage if @site
    @homepage ||= Page.homepage
    response_for :plural
  end

  def remove_with_back
    session[:came_from] = request.env["HTTP_REFERER"]
    remove_without_back
  end
  
  def continue_url_with_site(options={})
    options[:redirect_to] || (params[:continue] ? edit_admin_page_url(model) : admin_pages_url(:root => model.root.id))
  end
end
