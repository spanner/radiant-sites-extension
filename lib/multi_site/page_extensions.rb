# Unlike other scoped classes, there is no site association in the Page class. Instead, Site has a homepage association and Page has some retrieval methods that turn a page request into site information.

module MultiSite::PageExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :url, :sites
      mattr_accessor :current_site
      has_one :site, :foreign_key => "homepage_id", :dependent => :nullify
    }
    base.extend ClassMethods
    class << base
      def find_by_url(url, live=true)
        root = homepage
        raise Page::MissingRootPageError unless root
        root.find_by_url(url, live)
      end
    end
  end
  
  module ClassMethods
    def homepage
      if self.current_site.is_a?(Site)
        homepage = self.current_site.homepage
      end
      homepage ||= find_by_parent_id(nil)
    end
  end
  
  def url_with_sites
    if parent
      parent.child_url(self)
    else
      "/"
    end
  end
  
end
