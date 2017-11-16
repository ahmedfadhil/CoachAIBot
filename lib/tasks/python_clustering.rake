desc 'clusters the patients using a python script which performs ML clustering'
task :python_clustering => :environment do
  require "#{Rails.root}/lib/modules/cluster.rb"
  grouper = Cluster.new
  grouper.group_py
end
