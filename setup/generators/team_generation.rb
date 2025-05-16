# frozen_string_literal: true

TEAM_FILE = File.read('game_data/team_data.json').freeze
TEAM_DATA = JSON.parse(TEAM_FILE).freeze
TEAMS = []

TEAM_DATA.each do |team|
  group = team['members'].map do |member_id|
    CHARACTERS[member_id.to_sym]
  end

  TEAMS << Team.new(group, team['name'], team['description'])
end
