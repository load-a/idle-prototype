# frozen_string_literal: true

# @todo Change the game logic so that it uses Teams instead of Arrays

require_relative 'calendar'
require_relative 'off_time'

class Player
  attr_accessor :name, :character, :team, :money
  def initialize(name)
    self.name = Response.new('Alyssa').text # Input.ask("what is your name?").text
    character = CHARACTERS.find { |id, character| id.to_s.start_with?(self.name[0]) }&.last || CHARACTERS[:alyssa]
    self.character = character.from_zero
    self.team = Team.new([self.character], "#{self.name}'s Team", 'Your team')
    self.money = 100
  end
end

class Game
  # include Input
  # include Output

  attr_accessor :player, :calendar, :log

  def initialize
    self.player = Player.new(:alyssa)
    self.calendar = Calendar.new
    self.log = []
  end

  def test_play
    puts calendar.date
    puts player.team
  end

  def run_combat
    allied_team = team
    opposing_team = next_opponent

    combat_log = []

    [
      "#{allied_team.name} vs. #{opposing_team.name}".center(120),
      Output.four_stat_screen(allied_team.name, allied_team),
      "~~ #{allied_team.description} ~~".center(120),
      '',
      Output.four_stat_screen(opposing_team.name, opposing_team),
      "~~ #{opposing_team.description} ~~".center(120),
      ''
    ].each { |line| combat_log << line }

    encounter = Combat.start(allied_team, opposing_team)
    encounter.log.prepend(combat_log)
    encounter
  end

  def test_combat
    allied_team = TEAMS[0]
    opposing_team = TEAMS[2]

    [
      "#{allied_team.name} vs. #{opposing_team.name}".center(120),
      Output.four_stat_screen(allied_team.name, allied_team),
      "~~ #{allied_team.description} ~~".center(120),
      '',
      Output.four_stat_screen(opposing_team.name, opposing_team),
      "~~ #{opposing_team.description} ~~".center(120),
      ''
    ].flatten.each { |line| log << line }

    encounter = Combat.start(allied_team, opposing_team)
    log << encounter.log
  end
end
