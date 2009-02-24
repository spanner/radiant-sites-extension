module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
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
  
  # root parameter doesn't make sense in classes other than Page
  # which doesn't matter here but will do in other extensions
  # site parameter is just a site id
  # site_id cookie isn't needed here but is very useful elsewhere

  def index_with_site
    if params[:site] && site = Site.find(params[:site])
      current_site = @site = site

    elsif params[:root] && page = Page.find(params[:root])
      current_site = @site = page.root.site

    elsif cookies[:site_id] && !cookies[:site_id].nil? && site = Site.find(cookies[:site_id])
      current_site = @site = site

    else
      current_site || current_site = @site = Site.first(:order => "position ASC") || raise(MultiSite::SiteNotFound, "no site found", caller) 
    end

    set_current_site if @site
    @homepage ||= current_site.homepage || Page.find_by_parent_id(nil)
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
