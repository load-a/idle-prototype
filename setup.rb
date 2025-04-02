# frozen_string_literal: true

require 'json'

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
                                     character["power"].to_i, character["speed"].to_i, character["focus"].to_i, 
                                     {})

  character["traits"].each do |type, trait|
    CHARACTERS[symbol].traits[type.to_sym] = TRAITS[trait.to_sym]
  end
end
CHARACTERS.freeze


