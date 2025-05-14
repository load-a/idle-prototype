# frozen_string_literal: true

require_relative 'setup/setup'

game = Game.new(Player.new('Saramir'), Calendar.new, Inventory.new, House.new, Shop.new)

system 'clear'
game.test_play
# game.test_combat
