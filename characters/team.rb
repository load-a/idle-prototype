# frozen_string_literal: true

class Team
  attr_accessor :name, :members, :description

  def initialize(members, name = nil, description = nil)
    self.members = members 
    self.name = name || "#{members[0].name}'s Team"
    self.description = description || "#{members[0].name}'s Team"

    self.members = [members] unless members.is_a? Array
  end

  def method_missing(method, *args, &block)
    members.send(method, *args)
  end

  # Sees if both teams share any members
  def shares_members?(other_team)
    (members & other_team.members).any?
  end

  def same_size?(other_team)
    members.length == other_team.length
  end

  # Sees if both teams have the same exact members. Length is important, order is not.
  def same_members?(other_team)
    members.all? { |member| other_team.include? member }
  end

  def limit(range)
    range = (range..range) if range.is_a? Integer

    Team.new(members[range], name, description)
  end
end
