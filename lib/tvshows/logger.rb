class Logger

  def self.log(msg, title=nil)
    time = "\n#{Time.now.strftime('%a %d %b %H:%M:%S')}"
    title = "" unless title
    dots = "."*(25 - title.size)
    print "#{time} - [#{title}#{dots}] #{msg}"
    STDOUT.flush
  end

end