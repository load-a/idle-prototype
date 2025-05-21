# frozen_string_literal: true

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
