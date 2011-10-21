# Unlike other scoped classes, there is no site association in the Page class. Instead, Site has a homepage association and Page has some retrieval methods that turn a page request into site information.

module Sites::PageExtensions
  def self.included(base)
    base.class_eval {
      has_site
      mattr_accessor :current_site
      has_one :homed_site, :foreign_key => "homepage_id", :dependent => :nullify, :class_name => 'Site'
      alias_method_chain :path, :sites
    }
    
    class << base
      def current_site
        @current_site ||= Site.default
      end

      def current_site=(site)
        @current_site = site
      end

      def root_with_sites
        if self.current_site.is_a?(Site)
          self.current_site.homepage
        else
          root_without_sites
        end
      end
      alias_method_chain :root, :sites
    end
  end
  
  def path_with_sites
    if parent
      parent.child_path(self)
    else
      "/"
    end
  end

  # Climbs the page tree to find the root page and its site. 
  # Generally only used in migration or when mending site associations.
  #
  def ancestral_site
    if self.homed_site
      self.homed_site 
    elsif self.parent
      self.parent.ancestral_site
    else 
      Site.default
    end
  end

end
