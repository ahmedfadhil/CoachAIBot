
  #command '/usr/bin/some_great_command'
  #runner 'MyModel.some_method'
  #rake 'some:great:rake:task'


every :monday, :at => '4:49 pm' do
  runner 'Cluster.new.test'
end