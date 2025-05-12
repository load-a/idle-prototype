# frozen_string_literal: true

ITEM_FILE = File.read('game_data/item_data.json').freeze
ITEM_DATA = JSON.parse(ITEM_FILE).freeze

ABILITIES = {}
SUBSCRIPTIONS = {}
CONSUMABLES = {}
UPGRADES = {}

ITEM_DATA['abilities'].each do |id, ability|
  id = id.to_sym

  ABILITIES[id] = Item.new(id, :abilities, ability['cost'],  ability['description'])
end
ABILITIES.freeze

ITEM_DATA['consumables'].each do |id, ability|
  id = id.to_sym

  CONSUMABLES[id] = Item.new(id, :consumables, ability['cost'],  ability['description'])
end
CONSUMABLES.freeze

ITEM_DATA['upgrades'].each do |id, ability|
  id = id.to_sym

  UPGRADES[id] = Item.new(id, :upgrades, ability['cost'],  ability['description'])
end
UPGRADES.freeze

ITEM_DATA['subscriptions'].each do |id, ability|
  id = id.to_sym

  SUBSCRIPTIONS[id] = Item.new(id, :subscriptions, ability['cost'],  ability['description'])
end
SUBSCRIPTIONS.freeze
