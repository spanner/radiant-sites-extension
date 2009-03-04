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
        site_jumper if current_user
      end
      
      def site_jumper
        render :partial => 'admin/shared/site_jumper'
      end
      
    end
  end
end
