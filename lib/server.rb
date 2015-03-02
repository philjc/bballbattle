$:.unshift File.join(File.dirname(__FILE__))

require 'sinatra'
require 'date'
require 'picks'

set :static, true
set :bind, '0.0.0.0'
set :port, 8080
set :public_folder, './public'

def write_bracket
  puts get_current_time
  puts "starting..."
  file = File.open("data/bracket.json", "w")
  file.write(get_bracket.to_json)
  file.close
  puts "done"
end

get '/' do
  File.read('public/index.html')
end

get '/picks' do
  Picks.new("data/picks.csv", "data/bracket.json").to_json
end

get '/update_bracket' do
  write_bracket
end

get '/ideas' do
  require 'open-uri'
  open('http://localhost:9001/p/idea-pad').read
end
