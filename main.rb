# frozen_string_literal: true

require_relative 'setup/setup'
require_relative 'game/game'

game = Game.new

system 'clear'
game.test_play
# game.test_combat
