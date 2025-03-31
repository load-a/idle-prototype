# frozen_string_literal: true

require 'json'

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game'
require_relative 'special'



data_file = File.read('game_data.json')
game_data = JSON.parse(data_file)
character_data = game_data["characters"]
trait_data = game_data["traits"]

CHARACTERS = {}
TRAITS = {}

character_data.each do |character|
  name = character["name"]
  symbol = name.downcase.to_sym

  CHARACTERS[symbol] = Character.new(name, character["power"].to_i, {})

  character["specials"].each do |type, trait|
    CHARACTERS[symbol].specials[type.to_sym] = trait
  end
end

CHARACTERS.freeze


trait_data.each do |trait|
  TRAITS[trait["name"].to_sym] = Trait.new(trait["name"].capitalize, trait['description'], trait["type"].to_i)
end

TRAITS.freeze

puts TRAITS[:beast]

CHARACTERS[:alyssa].health = 5
puts CHARACTERS[:alyssa].status_line

# players = [CHARACTERS[:xia], CHARACTERS[:tomo]]
# count = 0

# loop do
#   count += 1
#   players.reverse!

#   puts "~ Round #{count} ~".center(80), "#{players[0].to_s} / #{players[1].to_s}".center(80)
#   Game.play_round(*players)

#   if !players[0].alive?
#     break puts "#{players[1].name} wins!"
#   elsif !players[1].alive?
#     break puts "#{players[0].name} wins!"
#   end
# end
