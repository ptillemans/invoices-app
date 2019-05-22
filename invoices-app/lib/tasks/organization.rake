
#
# Command-line interface to manage organizations
#
namespace :organization do

  desc "List all configured organizations"
  task :list => :environment do |t|
    Organization.all().each do |org|
      puts "#{org.name}: #{org.default_approver},#{org.backend}, #{org.viiper_dir_name}, #{org.viiper_dir_path}"
    end
  end

  desc 'Add a new organization.'
  task :add, [:name, :default_approver, :backend, :viiper_dir_name] => :environment do |t, args|
    puts "fields : #{args.to_hash}"
    Organization.create! args.to_hash
    puts "Record added."
  end

  desc 'Delete an organization.'
  task :delete, [:name] => :environment do |t, args|
    Organization.where(name: args[:name]).destroy_all
  end

  desc 'Modify an organization.'
  task :edit, [:name, :default_approver, :backend, :viiper_dir_name] => :environment do |t,args|
    Organization.where(name: args[:name]).take.update!(args.to_hash)
  end
end
