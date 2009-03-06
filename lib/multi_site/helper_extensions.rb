module MultiSite::HelperExtensions
  def self.included(base)

    base.module_eval do

      def default_page_title
        title + ' - ' + (current_site.subtitle || '')
      end

      def title
        current_site.name
      end

      def subtitle
        current_user && admin? ? site_jumper : current_site.subtitle
      end
      
      def site_jumper
        render :partial => 'admin/shared/site_jumper'
      end
      
    end
  end
end
