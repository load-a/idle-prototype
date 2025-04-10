# frozen_string_literal: true

require_relative 'setup'

game = Game.new

game.test_play

IO.write('game_log.txt', game.log.join("\n"))
