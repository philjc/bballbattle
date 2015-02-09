$:.unshift File.join(File.dirname(__FILE__))

require 'sinatra'
require 'ncaa_challenge'
require 'date'

set :static, true
set :bind, '0.0.0.0'
set :port, 8080

def write_bracket
  puts get_current_time
  puts "starting..."
  file = File.open("bracket.json", "w")
  file.write(get_bracket.to_json)
  file.close
  puts "done"
end

get '/' do
  File.read('public/index.html')
end

get '/picks' do
  bracket = JSON.parse(File.read("bracket.json"), {:symbolize_names => true})
  pick_details(bracket).to_json
end

get '/update_bracket' do
  write_bracket
end