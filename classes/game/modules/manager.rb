# frozen_string_literal: true

module GameManager
  def teammate_application
    return unless Dice.roll_high(20).crit

    character = CHARACTERS[next_opponent.members.sample.id]

    Output.new_screen "#{character.name} wants to join your crew.", character.attribute_chart.values[...5]

    allow_join = Input.confirm?('Let them?')

    if allow_join && player.team.length < 4
      add_new_teammate(character)
    elsif allow_join && player.team.length == 4 && Input.confirm?('You will have to let go of someone from your team.')
      puts player.team
      remove_teammate
      add_new_teammate(character)
    else
      notify "#{character.name} has not joined the team."
    end
  end

  def add_new_teammate(character)
    player.team.add_member(character)
    expenses << Expense.new(character.name, 'Daily living expenses', 40, :daily,
                            calendar.add_to_date(calendar.serialize_date, day: 1))
    notify "#{character.name} has joined the team!"
  end

  def remove_teammate
    return notify("Can't remove #{player.character.name} from their own team.") if player.team.length == 1

    character = Input.ask_option(*player.team.members[1..].map(&:name), prompt: 'Let go of which member?')

    return notify('Teammate removal canceled') if character.blank?

    character = player.team.members[character.index + 1]

    return unless Input.confirm?("Are you sure you want to let go of #{character.name}?")

    player.team.remove_member(character)
    expenses.reject! { |expense| expense.name == character.name }
    notify("#{character.name} has been let go from the team.")
  end
end
