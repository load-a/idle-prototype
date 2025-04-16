# frozen_string_literal: true

require_relative 'setup'

game = Game.new

# game.test_play
game.test_combat

IO.write('game_log.txt', game.log.join("\n"))
