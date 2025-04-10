# frozen_string_literal: true

module OffTime
  module_function

  def schedule_match(character, time)
    if %i[sleep out].include? character.schedule[time]
      return "Cannot schedule match for this time. #{character.name} will be #{character.schedule[time]}." 
    end

    character.schedule[time] = :match

    'Match scheduled for %02i:00' % time
  end

  def spend_hour(character)
    activity = character.tasks.shift.to_sym

    case activity
    when :sleep
      character.health = 20 unless character.health >= 20
    when :rest
      character.health += 1
    when :train
      character.focus += 1
    when :free
      if character.assignment.to_sym == :rest
        character.health += 1
      elsif character.assignment.to_sym == :train
        character.focus += 1
      else
        rand(0..1).zero? ? (character.health += 1) : (character.focus += 1)
      end
    else
      rand(0..1).zero? ? (character.health += 1) : (character.focus += 1)
    end
  end

  def check_times(character)
    hours = character.behavior.values.sum

    raise "#{character.name}'s hours do not sum to 24 #{character.behavior}" if hours != 24
  end

  def set_schedule(character)
    check_times(character)

    schedule = []
    sleep_time = []

    character.behavior.each do |type, length|
      length.times do
        if type == :sleep
          sleep_time << type
        else
          schedule << type
        end
      end
    end

    character.schedule = (sleep_time + schedule.shuffle).rotate(rand(0..6))
    character.tasks = character.schedule.dup
  end
end
