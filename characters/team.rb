# frozen_string_literal: true

# @todo convert team ledger into three arrays: Up, Downed and All Members

module TeamQueries
  def shares_members?(other_team)
    (members & other_team.members).any?
  end

  def same_size?(other_team)
    members.length == other_team.members.length
  end

  # Sees if both teams have the same exact members. Length is important, order is not.
  def same_members?(other_team)
    members.all? { |member| other_team.include? member }
  end

  def any?
    yield members.any?
  end

  def empty?
    members.empty?
  end

  def defeated?
    members.empty?
  end

  def include?(character)
    all_members.any? { |member| member.same_as? character }
  end

  def free?(time)
    members.none? do |member|
      %i[sleep out work].include? member.schedule[time]
    end
  end
end

module TeamFetch
  def limit(range)
    range = (range..range) if range.is_a? Integer

    Team.new(members[range], name, description)
  end

  def sample(number = 1)
    output = members.sample(number)
    return output.first if output.is_a? Array

    output
  end

  def length
    members.length + downed.length
  end
  alias size length

  def all_members
    members + downed
  end

  def leader
    all_members.find {|member| member.name = lineup.first}
  end
end

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
