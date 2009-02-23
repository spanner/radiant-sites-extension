module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :index, :root
      alias_method_chain :continue_url, :site
      alias_method_chain :remove, :back
      responses.destroy.default do 
        return_url = session[:came_from]
        session[:came_from] = nil
        redirect_to return_url || admin_pages_url(:root => model.root.id)
      end
    }
  end

  def index_with_root
    if params[:site] # If a root page is specified
      current_site = @site = Site.find(params[:site])

    elsif params[:root] # If a root page is specified
      @homepage = Page.find(params[:root])
      current_site = @site = @homepage.root.site

    elsif current_site
      @site = current_site

    else
      current_site = @site = Site.first(:order => "position ASC") || raise(MultiSite::SiteNotFound, "no site found", caller) 
    end

    set_current_site if @site
    @homepage ||= @site.homepage || Page.find_by_parent_id(nil)
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
