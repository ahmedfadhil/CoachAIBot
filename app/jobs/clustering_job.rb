class ClusterJob < ActiveJob::Base
  def perform
    Cluster.new.group
  end
end