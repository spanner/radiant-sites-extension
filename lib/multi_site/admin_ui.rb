module MultiSite::AdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :site
      alias_method :sites, :site

      def load_default_regions_with_site
        @site = load_default_site_regions
      end

      alias_method_chain :load_default_regions, :site

      protected

        def load_default_site_regions
          returning OpenStruct.new do |site|
            site.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_domain edit_homepage}
              edit.form_bottom.concat %w{edit_timestamp edit_buttons}
            end
            site.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header domain_header basedomain_header modify_header order_header}
              index.tbody.concat %w{title_cell domain_cell basedomain_cell modify_cell order_cell}
              index.bottom.concat %w{new_button}
            end
            site.remove = site.index
            site.new = site.edit
          end
        end
      
    end
  end
end

