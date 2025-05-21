# frozen_string_literal: true

class Formation

  attr_accessor :actor, :team

  def initialize(actor, team)
    self.actor = actor
    self.team = team
  end
end
