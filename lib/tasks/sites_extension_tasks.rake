namespace :radiant do
  namespace :extensions do
    namespace :sites do
      
      desc "Runs the migration of the Sites extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          SitesExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          SitesExtension.migrator.migrate
        end
      end
      
      desc "Handles the admin of moving from multi_site: most just noticing migrations that have already been made"
      task :from_multisite => :environment do
        require 'radiant/extension_migrator'
        last_ms_migration = ActiveRecord::Base.connection.select_values("SELECT version FROM #{ActiveRecord::Migrator.schema_migrations_table_name}").
          select { |version| version.starts_with?("Multi Site-")}.
          map { |version| version.sub("Multi Site-", '').to_i }.sort.last

        SitesExtension.migrator.new(:up, SitesExtension.migrations_path).send(:assume_migrated_upto_version, last_ms_migration) if last_ms_migration
      end
      
      desc "Copies public assets of the Sites extension to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from SitesExtension"
        Dir[SitesExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(SitesExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
