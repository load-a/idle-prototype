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
    self.members << character.from_zero
    character.set_schedule
  end

  def remove_member(character)
    members.reject! {|member| member.same_as? character}
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
end
