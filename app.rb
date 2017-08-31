require 'sinatra'
require 'date'
require 'json'
require 'securerandom'
require 'uri'
require 'net/http'
require 'active_support/inflector'

get '/' do
  content_type :json

  next_launch = fetch_next_launch

  better_date = next_launch[:date].strftime("%l:%M%p on %A, #{ActiveSupport::Inflector.ordinalize(next_launch[:date].day)} of %B")

  {
    uid: "urn:uuid:#{SecureRandom.uuid}",
    updateDate: "#{Time.now.utc.strftime('%FT%T')}.0Z",
    titleText: "The next launch will be by #{next_launch[:rocket]} in #{next_launch[:location]} at #{better_date}",
    mainText: "The next launch will be by #{next_launch[:rocket]} in #{next_launch[:location]} at #{better_date}",
    redicrectionURL: 'https://launchlibrary.net'
  }.to_json
end

def fetch_next_launch
  uri = URI('https://launchlibrary.net/1.2/launch/next/1')
  response = JSON.parse(Net::HTTP.get(uri))
  launch   = response['launches'].first
  {
    rocket:   launch['rocket']['name'],
    location: launch['location']['name'],
    date:     Time.parse(launch['net'])
  }
end
