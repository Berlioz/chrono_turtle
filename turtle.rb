require 'cinch'

class AlarmPlugin
  include Cinch::Plugin

  timer 10, method: :tick
  match //, method: :register

  def initialize
    @channels = []
  end

  def tick
    @channels.each do |channel|
      channel.send "tick"
    end
  end

  def register(m)
    @channels.add (m.channel)
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