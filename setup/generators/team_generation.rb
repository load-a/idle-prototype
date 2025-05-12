# frozen_string_literal: true

TEAM_FILE = File.read('game_data/team_data.json').freeze
TEAM_DATA = JSON.parse(TEAM_FILE).freeze
TEAMS = []

TEAM_DATA.each do |team|
  group = Team.new([], team['name'], team['description'])

  team['members'].each do |member_id|
    group.members << CHARACTERS[member_id.to_sym]
  end

  TEAMS << group
end
