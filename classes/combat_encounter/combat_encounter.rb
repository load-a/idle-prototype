# frozen_string_literal: true

require_relative 'match/match'

class CombatEncounter
  attr_accessor :log, :encounter

  def initialize(player_team, cpu_team)
    self.encounter = Match.new(player_team, cpu_team)
    encounter.play

    self.log = encounter.log
  end

  def method_missing(method_name, *_args)
    encounter.send(method_name)
  end
end
