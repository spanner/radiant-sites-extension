module MultiSite::ResourceControllerExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :find_current_site, :options
    }
  end

  def current_site=(site=nil)
    if site && site.is_a?(Site)
      @current_site = site
      cookies[:site_id] = { :value => site.id.to_s }
    end
  end

  def find_current_site_with_options
    site_from_param || site_from_cookie || find_current_site_without_options
  end

  def site_from_cookie
    cookies[:site_id] && Site.find(cookies[:site_id]) rescue nil
  end

  def site_from_param
    params[:site_id] && Site.find(params[:site_id]) rescue nil
  end

end
