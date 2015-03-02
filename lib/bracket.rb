require 'set'
require 'json'
require 'team.rb'
require 'game.rb'

def get_bracket()
  # based on bracket located at http://www.ncaa.com/interactive-bracket/basketball-men/d1
  response = %x[curl -s http://data.ncaa.com/jsonp/gametool/brackets/championships/basketball-men/d1/2013/data.json]
  json = JSON.parse(response[response.index("(")+1..-3], {:symbolize_names => true})
  json[:update_time] = get_current_time
  json
end

def write_bracket
  puts get_current_time
  puts "starting..."
  file = File.open("bracket.json", "w")
  file.write(get_bracket.to_json)
  file.close
  puts "done"
end

def parse_bracket(bracket_file)
  JSON.parse(File.read(bracket_file), {:symbolize_names => true})[:games]
end

def get_teams(bracket_file)
  games = parse_bracket(bracket_file)
  teams = {}

  games.each do |game| 
    away = Team.from_json(game, :away)
    teams[away.name] = away
    home = Team.from_json(game, :home)
    teams[home.name] = home
  end

  teams
end

def get_matchups(bracket_file)
  games = parse_bracket(bracket_file)
  matchups = []

  games.each do |game|
    matchups << Game.from_json(game)
  end

  matchups
end