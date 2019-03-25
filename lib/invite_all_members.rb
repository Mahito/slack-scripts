require 'slack-ruby-client'

Slack::Web::Client.configure do |config|
  config.token = ENV['SLACK_API_USER_TOKEN']
  raise 'Missing ENV[SLACK_API_USER_TOKEN]!' unless config.token

  STDOUT.sync = true

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

logger = Logger.new(STDOUT)
web = Slack::Web::Client.new

if ARGV.size != 2
  logger.error('Command Error: invite_all_members [channel_name] [topic]')
else
  channel, topic = ARGV
  channel_id = web.channels_create(name: channel).channel['id']
  web.channels_setTopic(channel: channel_id, topic: topic)
  web.users_list.members.each do |member|
    next if member['is_bot']
    next if member['deleted']
    begin
      web.channels_invite(channel: channel_id, user: member['id'])
      sleep(0.5)
    rescue Slack::Web::Api::Errors::SlackError => e
      logger.error(e)
      next
    end
  end
end
