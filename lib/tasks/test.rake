desc 'test whenever'
task :test => :environment do
  require "#{Rails.root}/lib/modules/cluster.rb"
  Cluster.new.test
end
