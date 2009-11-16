module MultiSite::ScopedValidation

  def self.included(base)

    base.class_eval do
      # scoping validations to the site should be very simple 
      # all you would normally need is something like this:
      #
      #   validates_uniqueness_of :email, :scope => :site_id
      #
      # but if you want to scope core radiant classes, you have a problem:
      # their uniqueness validations have already been declared
      # The only answer is to reach right back and change the validates_uniqueness_of method
      # and to make it more awkward, that has to happen so early that we can't reflect on the site association.
      # Hence the check for a site_id column. It's a hack, but a fairly harmless one.

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
