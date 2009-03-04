module MultiSite::ScopedValidation

  def self.included(base)

    def validates_uniqueness_of_with_site(*attr)
      
      # this is a shoddy assumption, but at least if site_id is not in use it will have no effect
      # and if table doesn't exist it's presumably because we're migrating. calling column_names
      # in that situation is not helpful

      if table_exists? && column_names.include?('site_id')         
        configuration = attr.extract_options!
        configuration[:scope] ||= :site_id
        attr.push(configuration)
      end
      validates_uniqueness_of_without_site(*attr)  
    end
    
    # the respond_to? condition is to block multiple definitions in dev mode. stacks otherwise.
    
    base.alias_method_chain :validates_uniqueness_of, :site unless base.instance_methods.include?(:validates_uniqueness_of_without_site)
  end
end
