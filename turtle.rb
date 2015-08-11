require 'cinch'
require 'open-uri'
require 'json'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  
TICK_TIME = 60

class PadHerder
  def self.events_api
    JSON.parse(open("https://www.padherder.com/api/events/").read)
  end

  def self.events(now, previous)
    events_api.select do |event|
      event_time = Time.iso8601(event["starts_at"])
      event_time > previous && event_time < now
    end
  end
end

class AlarmPlugin
  include Cinch::Plugin

  timer TICK_TIME, method: :tick
  listen_to :channel

  def tick
    if @recently_sent
      @recently_sent = false
      return
    end
    @channels ||= []

    notices = []
    now = Time.now
    events = PadHerder.events(now, now - (TICK_TIME + 10))
    events.each do |event|
      notices << "#{event["country"] == 2 ? 'US' : 'JP'} group #{event["group_name"]}: #{event["title"]} is starting!"
    end

    if notices.length > 0
      @recently_sent = true
    end

    @channels.each do |channel|
      notices.each do |notice|
        channel.send notice
      end
    end
  end

  def listen(m)
    @channels ||= []
    @channels << (m.channel)
  end
end

bots = 
[Cinch::Bot.new do
  configure do |c|
    c.nick            = "chrono_turtle"
    c.server          = "irc.synirc.org"
    c.channels        = ["#pad"]
    c.plugins.plugins = [AlarmPlugin]
  end
end,
Cinch::Bot.new do
  configure do |c|
    c.nick            = "chrono_turtle"
    c.server          = "irc.freenode.org"
    c.channels        = ["#redditpad", "#csuapad"]
    c.plugins.plugins = [AlarmPlugin]
  end
end]

workers = bots.map do |bot|
  Thread.new do
    bot.start
  end
end
workers.each do |thread|
  thread.join
end 
