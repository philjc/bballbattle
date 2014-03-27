require 'json'
require 'date'

#1 seeds = one point per win
#2 and 3 seeds = two points per win
#4 and 5 seeds = three points per win
#6, 7 and 8 seeds = four points per win
#9, 10 and 11 seeds = five points per win
#12 and 13 seeds = six points per win
#14 and 15 seeds = seven points per win
#16 seeds = eight points per win

@bracket = nil

def get_points(seed)
seed_to_points = {
                  1 => 1,
                  2 => 2,
                  3 => 2,
                  4 => 3,
                  5 => 3,
                  6 => 4,
                  7 => 4,
                  8 => 4,
                  9 => 5,
                  10 => 5,
                  11 => 5,
                  12 => 6,
                  13 => 6,
                  14 => 7,
                  15 => 7,
                  16 => 8
                  }
                  seed_to_points[seed]
end

def get_bracket()
  response = %x[curl -s http://data.ncaa.com/jsonp/gametool/brackets/championships/basketball-men/d1/2013/data.json]
  json = JSON.parse(response[response.index("(")+1..-3], {:symbolize_names => true})
end

def knocked_out?(bracket, team)
  bracket[:games].each do | game |
    if game[:round].to_i > 1 && game[:gameState] == "final"
      if game[:home][:winner] == "false" && game[:home][:names][:short] == team
        return true
      end
      if game[:away][:winner] == "false" && game[:away][:names][:short] == team
        return true
      end
    end
  end

  false
end

def get_picks(bracket)
  player_picks = {}
  File.readlines("data/picks.csv").each do | line |
    split = line.split(',')
    player = split[0]
    player_picks[player] = {}
    picks = split[1..split.length - 2]
    picks.each do | pick |
      psplit = pick.split(" ")
      seed = psplit[0]
      team = psplit[1..psplit.length - 1].join(" ")
      knocked_out = knocked_out?(bracket, team)
      player_picks[player][team] = { :seed => seed, :knocked_out => knocked_out }
    end
  end
  player_picks
end

def sum_total(bracket, picks)
  sum = 0
  bracket[:games].each do | game |
    if game[:round].to_i > 1 && game[:gameState] == "final"
      name = ""
      if game[:home][:winner] == "true"
        name = game[:home][:names][:short]
      elsif game[:away][:winner] == "true"
        name = game[:away][:names][:short]
      end
      pick = picks[name]
      if pick != nil
        sum += get_points(pick[:seed].to_i)
      end
    end
  end
  sum
end

def pick_details(bracket)
  json = {}
  player_picks = get_picks(bracket)
  player_picks.each do | player, picks |
    total = sum_total(bracket, picks)
    json[player] = { :picks => picks, :total => total }
  end
  json
end
