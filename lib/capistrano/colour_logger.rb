class ColourfulCapLogger < Capistrano::Logger

  def log(level, message, line_prefix=nil, ansi='')
    if level <= self.level
      indent = format("%#{MAX_LEVEL}s", "*" * (MAX_LEVEL - level))
      if line_prefix
        line_prefix_str = " \e[1;30m[\e[0m#{line_prefix}\e[1;30m]\e[0m"
      else
        line_prefix_str = ''
      end
      message.each do |line|
        device.puts "#{ansi}#{indent}#{line_prefix_str} #{ansi}#{line.strip}\e[0m\n"
      end
    end
  end

  def important(message, line_prefix=nil)
    log(IMPORTANT, message, line_prefix, "\e[1;31m") # red
  end

  def info(message, line_prefix=nil)
    log(INFO, message, line_prefix, "\e[0;32m") # green
  end

  def debug(message, line_prefix=nil)
    case message
    when /^executing \"/ # shell command
      log(DEBUG, message, line_prefix, "\e[0;33m") # brown
    when /^executing `/ # task
      log(DEBUG, message, line_prefix, "\e[0;36m") # cyan
    else
      log(DEBUG, message, line_prefix) # default colour
    end
  end

  def trace(message, line_prefix=nil)
    log(TRACE, message, line_prefix) # default colour
  end
end

# ColourfulCapLogger overriding the existing instance
oldlogger = @logger
@logger = ColourfulCapLogger.new(:output => $stdout) # default is $stderr which is annoying
@logger.level = oldlogger.level
