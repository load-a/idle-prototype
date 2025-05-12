# frozen_string_literal: true

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
