#require 'active_support/all'
require 'json'
require 'open-uri'
require 'builder'
require 'bunny'


# ruby rabbitmq-publish2.rb /Users/min/Desktop/NHL_SCHEDULE-1459833896.XML web2.integration amqp://swxpqdte:4hNK7FxsuBz6C0JexIRLpvOtobKOmNVH@purple-mink.rmq.cloudamqp.com/swxpqdte
# bundle exec ruby scripts/rabbitmq-publish2.rb "/working/09/*.XML" integration amqp://zpsdtudk:nKgecOMaEK5y17ddGadlIeHu1vmodT7D@brown-ferret.rmq.cloudamqp.com/zpsdtudk

# http://api.sportradar.us/nhl-t3/players/e6fc4e06-9c16-11e2-a01b-f4ce4684ea4c/profile.xml?api_key=72y3gdnjr43qbnydacyyr38n

pattern = ARGV[0]
queue = ARGV[1]


conn = Bunny.new.start
channel = conn.create_channel

exchange = channel.topic('sn.exchange', durable: true)

#prefix = 'http://mobileapp-elasticl-l0g6xu1571v2-1583716606.us-east-1.elb.amazonaws.com'

#key="DAF52EAD3A5F7"

#api_key = "72y3gdnjr43qbnydacyyr38n"

routing_key='sn.integration.test'
player_url = "http://api.sportradar.us/nhl-t3/players/e6fc4e06-9c16-11e2-a01b-f4ce4684ea4c/profile.json?api_key=72y3gdnjr43qbnydacyyr38n"
player_data = open(player_url).read rescue nil

xml = Builder::XmlMarkup.new( :indent => 2 )
xml.instruct! :xml, :encoding => "UTF-8"
xml.skaters(id: 1000, team_id: 1001, at: Time.now.to_i) do |p|
  xml.cdata! player_data
end
topic = "NHL_SPORTSRADAR_player1-#{Time.now.to_i}.XML"
File.open(topic, 'w').write(xml.target!)
exchange.publish({ filename: topic, content: xml.target! }.to_json,
                 routing_key: routing_key,
                 persistent: true, durable: true)

conn.stop