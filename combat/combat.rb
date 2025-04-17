# frozen_string_literal: true

require_relative 'combat_output'
require_relative 'combat_methods'
require_relative 'round'
require_relative 'match'

module Combat
  module_function

  def start(home_team, away_team)
    game = Match.new(home_team, away_team)

    game.play

    game.log
  end
end
