class Logger

  def self.log(msg, title=nil, sticky=false, show_time=true)
    time = show_time ? "\n#{Time.now.strftime('%a %d %b %H:%M:%S')}" : ''
    #Growl.notify "#{msg}#{time}", :title=>title, :sticky=>sticky
    title = "" unless title
    dots = "."*(25 - title.size)
    print "#{time} - [#{title}#{dots}] #{msg}"
    STDOUT.flush
  end

end