# frozen_string_literal: true

module TeamMembers
  def add_member(character)
    character.set_schedule
    members << character.from_zero
  end

  def remove_member(character)
    members.reject! { |member| member.same_as? character }
  end
end
