require 'cinch'

class AlarmPlugin
  include Cinch::Plugin

  timer 10, method: :tick
  listen_to :channel

  def tick
    @channels ||= []

    @channels.each do |channel|
      channel.send "tick"
    end
  end

  def listen(m)
    @channels ||= []
    @channels << (m.channel)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "chrono_turtle"
    c.server          = "irc.synirc.org"
    c.channels        = ["#asterbot-staging"]
    c.plugins.plugins = [AlarmPlugin]
  end
end

bot.start
