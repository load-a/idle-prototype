# frozen_string_literal: true

require 'json'

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game/game'
require_relative 'special'

data_file = File.read('game_data.json').freeze

game_data = JSON.parse(data_file).freeze

CHARACTER_DATA = game_data["characters"].freeze
TRAIT_DATA = game_data["traits"].freeze

TRAITS = {}
TRAIT_DATA.each do |trait|
  TRAITS[trait["name"].to_sym] = Trait.new(trait["name"], trait['description'], trait["type"].to_i)
end
TRAITS.freeze

CHARACTERS = {}
CHARACTER_DATA.each do |character|
  name = character["name"]
  symbol = name.downcase.to_sym

  CHARACTERS[symbol] = Character.new(name, 
                                     character["health"].to_i, character["power"].to_i, 
                                     character["focus"].to_i, character["speed"].to_i, 
                                     {}, {})

  character["traits"].each do |type, trait|
    CHARACTERS[symbol].traits[type.to_sym] = TRAITS[trait.to_sym]
  end

  character["behavior"].each do |type, length|
    CHARACTERS[symbol].behavior[type.to_sym] = length.to_i 
  end
end
CHARACTERS.freeze


