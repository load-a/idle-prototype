# frozen_string_literal: true

require 'json'
require 'rainbow'

require_relative 'characters/character'
require_relative 'dice'
require_relative 'game/game'
require_relative 'combat/combat'

data_file = File.read('game_data.json').freeze

game_data = JSON.parse(data_file).freeze

CHARACTER_DATA = game_data["characters"].freeze
TRAIT_DATA = game_data["traits"].freeze
TEAM_DATA = game_data["teams"].freeze

Trait = Struct.new(:id)

TRAITS = {}
TRAIT_ALIASES = {}
TRAIT_DATA.each do |trait|
  id = trait["id"].to_sym

  TRAITS[id] = Trait.new(id) 
end
TRAITS.freeze

CHARACTERS = {}
CHARACTER_DATA.each do |character|
  name = character["name"]
  id = character["id"].to_sym

  CHARACTERS[id] = Character.new(name,
                                     character["health"].to_i, character["power"].to_i, 
                                     character["focus"].to_i, character["speed"].to_i)

  character["traits"].each do |type, trait_name|
    CHARACTERS[id].traits[type.to_sym] = TRAITS[trait_name.to_sym]
  end

  character["behavior"].each do |type, length|
    CHARACTERS[id].behavior[type.to_sym] = length.to_i 
  end

  CHARACTERS[id].max_cost = character["cost"].to_i
  CHARACTERS[id].cost = CHARACTERS[id].max_cost
end
CHARACTERS.freeze

TEAMS = []
TEAM_DATA.each do |team|
  group = Team.new([], team["name"], team["description"])

  team["members"].each do |member_id|
    group.members << CHARACTERS[member_id.to_sym]
  end

  TEAMS << group
end
