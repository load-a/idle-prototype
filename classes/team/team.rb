# frozen_string_literal: true

require_relative 'fetch'
require_relative 'queries'

# @todo convert team ledger into three arrays: Up, Downed and All Members

class Team
  include TeamQueries
  include TeamFetch

  attr_accessor :name, :members, :description, :downed, :lineup

  def initialize(members, name = nil, description = nil)
    self.members = members
    self.lineup = members.map(&:name)
    self.name = name || "#{members[0].name}'s Team"
    self.description = description || "#{members[0].name}'s Team"

    self.members = [members] unless members.is_a? Array
    self.downed = []
  end

  def add_member(character)
    character.set_schedule
    members << character.from_zero
  end

  def remove_member(character)
    members.reject! { |member| member.same_as? character }
  end

  def to_s
    [
      name.center(120),
      Output.four_stat_screen(name, self),
      "^^ #{description} ^^".center(120)
    ].join("\n")
  end

  def remove_defeated
    members.each do |member|
      downed << member if member.down?
    end

    members.reject!(&:down?)
  end

  def restore_defeated
    downed.each do |member|
      member.recover(1)
      members << member
    end

    downed.clear
  end

  def schedule_match(time)
    members.each { |member| member.schedule[time] = :match }
  end

  def challenge_rating(other_team)
    might - other_team.might
  end

  def might
    members.map do |member|
      member.power + member.max_focus + Dice.inverse_die(member.speed) + 
      (member.traits.values.count {|trait| trait != NO_ITEM} * 12) +
      member.max_health
    end.sum
  end

  def serialize
    serial_hash = {
      'members' => []
    }

    members.each_with_index { |member, _index| serial_hash['members'] << member.serialize }
    serial_hash['name'] = name
    serial_hash['description'] = description

    serial_hash
  end

  def deserialize(serial_hash)
    members.clear

    serial_hash['members'].each do |member_hash|
      members << CHARACTERS[member_hash['id'].to_sym].deserialize(member_hash)
    end

    members.each(&:set_schedule)

    self.name = serial_hash['name']
    self.description = serial_hash['description']

    self
  end
end
