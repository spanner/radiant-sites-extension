module MultiSite::ScopedValidation

  def self.included(base)

    base.class_eval do
          
      # the site_id check is a hack but all this has to happen very early on and we can't reflect on associations yet

      def validates_uniqueness_of_with_site(*attr)
        if table_exists? && column_names.include?('site_id')
          configuration = attr.extract_options!
          configuration[:scope] ||= :site_id
          attr.push(configuration)
        end
        validates_uniqueness_of_without_site(*attr)
      end

      alias_method_chain :validates_uniqueness_of, :site
    end
    
  end
end

ActiveRecord::Validations::ClassMethods.send :include, MultiSite::ScopedValidation
