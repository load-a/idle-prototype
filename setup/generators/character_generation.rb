# frozen_string_literal: true

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
    CHARACTERS[id].traits[type.to_sym] = if trait_name == 'none'
                                           NO_ITEM
                                         else
                                           ABILITIES[trait_name.to_sym]
                                         end
  end

  data['behavior'].each do |type, length|
    CHARACTERS[id].behavior[type.to_sym] = length.to_i
  end

  CHARACTERS[id].max_cost = data['cost'].to_i
  CHARACTERS[id].cost = CHARACTERS[id].max_cost
end
CHARACTERS.freeze
