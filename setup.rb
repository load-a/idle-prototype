# frozen_string_literal: true

require 'json'
require 'rainbow'

require_relative 'input'
require_relative 'output'
require_relative 'characters/character'
require_relative 'dice'
require_relative 'game/game'
require_relative 'combat/combat'
require_relative 'items/item'

SPEED_MULTIPLIER = {
  '2' => 3.5,
  '4' => 3,
  '6' => 2.5,
  '8' => 2,
  '10' => 1.5,
  '12' => 1,
  '20' => 0.5
}.freeze

ITEM_FILE = File.read('game_data/item_data.json').freeze
ITEM_DATA = JSON.parse(ITEM_FILE).freeze
ABILITY_DATA = ITEM_DATA['abilities']
ABILITIES = {}

ABILITY_DATA.each do |id, ability|
  id = id.to_sym

  ABILITIES[id] = Item.new(id, :ability, ability['cost'],  ability['description'])
end
ABILITIES.freeze

CHARACTER_FILE = File.read('game_data/character_data.json').freeze
CHARACTER_DATA = JSON.parse(CHARACTER_FILE).freeze
CHARACTERS = {}

CHARACTER_DATA.each do |id, data|
  name = data['name']
  id = id.to_sym

  CHARACTERS[id] = Character.new(name, id,
                                 data['health'].to_i, data['power'].to_i,
                                 data['focus'].to_i, data['speed'].to_i)

  data['traits'].each do |type, trait_name|
    if trait_name == "none"
      CHARACTERS[id].traits[type.to_sym] = NO_ITEM
    else
      CHARACTERS[id].traits[type.to_sym] = ABILITIES[trait_name.to_sym]
    end
  end

  data['behavior'].each do |type, length|
    CHARACTERS[id].behavior[type.to_sym] = length.to_i
  end

  CHARACTERS[id].max_cost = data['cost'].to_i
  CHARACTERS[id].cost = CHARACTERS[id].max_cost
end
CHARACTERS.freeze

TEAM_FILE = File.read('game_data/team_data.json').freeze
TEAM_DATA = JSON.parse(TEAM_FILE).freeze
TEAMS = []

TEAM_DATA.each do |team|
  group = Team.new([], team['name'], team['description'])

  team['members'].each do |member_id|
    group.members << CHARACTERS[member_id.to_sym]
  end

  TEAMS << group
end
