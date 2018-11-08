namespace :unicorn do
  ##
  # Tasks
  ##
  desc "Start unicorn for development env."
  task(:start) {
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c #{config} -E #{ENV["RAILS_ENV"]} -D"
  }

  desc "Stop unicorn"
  task(:stop) { unicorn_signal :QUIT }

  desc "Restart unicorn with USR2"
  task(:restart) {
    # unicorn_signal :USR2
    # ↑だと古いprocessが残るので一度落としてから起動
    unicorn_signal :QUIT
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c #{config} -E #{ENV["RAILS_ENV"]} -D"
  }

  desc "Increment number of worker processes"
  task(:increment) { unicorn_signal :TTIN }

  desc "Decrement number of worker processes"
  task(:decrement) { unicorn_signal :TTOU }

  desc "Unicorn pstree (depends on pstree command)"
  task(:pstree) do
    sh "pstree '#{unicorn_pid}'"
  end

  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      File.read("#{Rails.root.to_s}/tmp/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end

end