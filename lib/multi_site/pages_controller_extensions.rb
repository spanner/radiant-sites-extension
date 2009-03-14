module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :find_current_site, :root
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

  def find_current_site_with_root
    logger.warn ">>> find_current_site_with_root"
    site_from_root || find_current_site_without_root
  end

  def site_from_root
    logger.warn ">>> site_from_root"
    if params[:root] && @homepage = Page.find(params[:root])
      @site = @homepage.root.site
    end
  end

  def index_with_site
    @site ||= current_site
    @homepage ||= @site.homepage || Page.find_by_parent_id(nil)
  end

  def remove_with_back
    session[:came_from] = request.env["HTTP_REFERER"]
    remove_without_back
  end
  
  def continue_url_with_site(options={})
    options[:redirect_to] || (params[:continue] ? edit_admin_page_url(model) : admin_pages_url(:root => model.root.id))
  end
end
