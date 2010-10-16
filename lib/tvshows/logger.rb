class Logger

  def self.log(msg, title=nil, sticky=false, show_time=true)
    time = show_time ? "\n#{Time.now.strftime('%a %d %b %H:%M:%S')}" : ''
    Growl.notify "#{msg}#{time}", :title=>title, :sticky=>sticky
    puts "#{time} - #{msg}"
  end

end