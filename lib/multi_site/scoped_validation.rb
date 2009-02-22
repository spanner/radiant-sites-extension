module MultiSite::ScopedValidation

  def self.included(base)

    def validates_uniqueness_of_with_site(*attr)
      if column_names.include?('site_id')         # this is a nasty assumption, but anything programmatic is too late
        configuration = attr.extract_options!
        configuration[:scope] ||= :site_id
        configuration[:message] += " on this site"
        attr.push(configuration)
      end
      
      validates_uniqueness_of_without_site(*attr)  
    end
    
    base.alias_method_chain :validates_uniqueness_of, :site

  end
end
