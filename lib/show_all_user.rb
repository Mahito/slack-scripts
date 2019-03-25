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

web.users_list.members.each do |member|
  next if member['is_bot']
  next if member['deleted']
  begin
    username = member['profile']['display_name']
    username = member['real_name'] if username == ""
    username = member['name'] if username == ""
    puts "#{username}: #{member['id']}"
  rescue Slack::Web::Api::Errors::SlackError => e
    logger.error(e)
    next
  end
end
