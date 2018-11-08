# -*- coding: utf-8 -*-
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 150
preload_app true  # 更新時ダウンタイム無し
working_directory '/home/maharu/lesson2'
listen "/home/maharu/lesson2/tmp/unicorn.sock"
pid "/home/maharu/lesson2/tmp/unicorn.pid"


#listen File.expand_path('/tmp/sockets/unicorn.sock', __FILE__)
#pid File.expand_path('/tmp/pids/unicorn.pid', __FILE__)
#listen "/tmp/sockets/unicorn.sock"
#pid "/tmp/pids/unicorn.pid"


before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end

# ログの出力
stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
