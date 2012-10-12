worker_processes 3
timeout 30
preload_app true


before_fork do |server, worker|
  ConnectionReloader.disconnect!

  #sleep 1
end

after_fork do |server, worker|
  ConnectionReloader.connect!
end
