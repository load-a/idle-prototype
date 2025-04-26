# frozen_string_literal: true

module TimeMenu
  def time_menu
    loop do
      system 'clear'
      show_time_screen

      response = Input.ask_char('Pick an action (or go [B]ack)').character
      case response
      when 'b', 'q'
        break
      when 'e'
        puts 'Edit not implemented'
      when 'p'
        hours = number_of_hours
        pass_time(hours)
        break
      else
        notify "DEBUG: Invalid Input: Timetable > [#{response}]"
      end
    end
  end

  def show_time_screen
    team = player.team.members
    header = Output.columns(team.map(&:name),
                            row_headers: ['Time    '], content_just: :center,
                            right_edge: '|', left_edge: '|',
                            left_div: '|')

    puts header, header[0].gsub(/\w|\s/, '-')

    timetable = Output.columns(team.map(&:schedule), row_headers: calendar.hour_array,
                                                     right_edge: '|', left_edge: '|', header_just: :rjust,
                                                     left_div: '|')

    display_timetable(timetable)
  end

  def display_timetable(timetable)
    timetable.each_with_index do |line, hour|
      line = color_activity(line)
      line = color_placement(line, hour)
      puts line
    end
  end

  def color_activity(line)
    if line =~ /(match)/
      Rainbow(line).blue
    elsif line !~ /(work|sleep|out)/
      Rainbow(line).yellow
    else
      line
    end
  end

  def color_placement(line, hour)
    if hour < calendar.hour
      Rainbow(line).faint
    elsif hour == calendar.hour
      Rainbow(line).bold
    else
      line
    end
  end

  def pass_time(hours = 1)
    return if hours.zero?

    team = player.team.members

    hours.times do
      notify '~~ %02i:00 ~~' % calendar.hour
      team.each do |teammate|
        break start_match if teammate.schedule[calendar.hour] == :match

        notify teammate.do_task(calendar.hour)
      end

      advance_time(team)
    end
  end

  def number_of_hours
    hours = Input.ask('How many hours: ').number

    if (0..24).include?(hours)
      hours
    else
      0
    end
  end

  def start_match
    encounter = run_combat
    self.combat_log = encounter.log
    notify earn_money(encounter)
  end

  def advance_time(team)
    calendar.advance_hour

    return unless calendar.hour.zero?

    notify calendar.day_month
    team.each(&:set_schedule)
    self.next_opponent = nil
  end
end
