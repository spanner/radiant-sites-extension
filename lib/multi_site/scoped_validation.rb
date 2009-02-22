module MultiSite::ScopedValidation

  def self.included(base)

    def validates_uniqueness_of_with_site(*attr)
      if column_names.include?('site_id')         # this is a nasty assumption, but at least if site_id is not in use it will have no effect
        configuration = attr.extract_options!
        configuration[:scope] ||= :site_id
        attr.push(configuration)
      end
      validates_uniqueness_of_without_site(*attr)  
    end
    
    # the condition is to block multiple definitions in dev mode and possibly even avoid stacking
    base.alias_method_chain :validates_uniqueness_of, :site unless base.respond_to?(:validates_uniqueness_of_without_site)
  end
end
