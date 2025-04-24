# frozen_string_literal: true

module OffTime
  module_function

  def check_times(character)
    hours = character.behavior.dup
    hours.reject! { |task, _hours| task == :job }
    hours = hours.values.sum

    raise "#{character.name}'s hours do not sum to 24 #{character.behavior}" if hours != 24
  end

  def set_schedule(character)
    check_times(character)

    schedule = []
    sleep_time = []

    character.behavior.each do |type, length|
      length.times do
        case type
        when :sleep
          sleep_time << type
        when :free
          schedule << if character.assignment == :job && schedule.count(:job) < character.behavior[:job]
                        :job
                      elsif %i[job free].include? character.assignment
                        %i[train rest out].sample
                      else
                        character.assignment
                      end
        when :job
          next
        else
          schedule << type
        end
      end
    end

    character.schedule = schedule.shuffle

    if !character.behavior[:job].zero? && rand(7) < 5
      shift = rand(0..character.behavior[:job])
      latest_start = schedule.length - shift - 1
      start_time = rand(0...latest_start)
      end_time = start_time + (shift - 1)

      character.schedule.fill(:job, start_time..end_time)
    end

    character.schedule += sleep_time
    character.schedule.rotate!(rand(-8..-4))
  end
end
