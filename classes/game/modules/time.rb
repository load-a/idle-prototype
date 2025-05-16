# frozen_string_literal: true

module GameTime
  SLEEP_TEXT = [
    'had a weird dream', 'was visited by the Sandman', 'slept', 'snored really loudly', 'talked in their sleep',
    'restored the old tissues with an hour of the dreamless', "didn't dream", 'counted sheep',
    'woke up to pee', 'had a nice dream', 'had a bad dream', 'fell out of bed', "couldn't sleep"
  ]
  FREE_TEXT = [
    'enjoyed some free time', 'went for a walk', 'visited a friend', 'meditated',
    'read a book', 'enjoyed their hobby'
  ]
  WORK_TEXT = [
    'got that bag', 'was at work', 'made some money', 'scrolled online while at work'
  ]
  TRAINING_TEXT = [
    'hit up the iron church', 'got some reps in', 'trained', 'worked out', 'studied the ancient texts',
    'worked on their technique', 'practiced', 'did some stretches'
  ]
  REST_TEXT = [
    'took a nap', 'ate something', 'drank some water', 'took a shower',
    'took a bath', 'had some tea', 'had a snack'
  ]

  def time_menu
    loop do
      Output.new_screen
      show_time_screen

      response = Input.ask_option(*%w[pass], prompt: 'Pick an action')
      case response.line
      # when 'edit'
      #   puts 'Edit not implemented'
      when 'pass'
        hours = number_of_hours
        pass_time(hours)
        break
      else
        break
      end
    end
  end

  def show_time_screen
    team = player.team.members
    header = Output.columns(team.map(&:name),
                            row_headers: ['Time    '], content_just: :center,
                            right_edge: '|', left_edge: '|',
                            left_div: '|')
    divider = header[0].gsub(/\w|\s/, '-')

    puts header, divider

    timetable = Output.columns(team.map(&:schedule), row_headers: calendar.hour_array,
                                                     right_edge: '|', left_edge: '|', header_just: :rjust,
                                                     left_div: '|')

    display_timetable(timetable)
    puts divider.gsub('-', '_')
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

        do_activity(teammate)
      end

      advance_time(team)
    end
  end

  def number_of_hours
    hours = Input.ask_number('How many hours: ')

    if (1..24).include?(hours)
      hours
    else
      notify('NOTE: Can only pass between 1 and 24 hours.')
      0
    end
  end

  def advance_time(team)
    calendar.advance_hour
    generate_challengers

    return unless calendar.hour.zero?

    notify calendar.day_month
    pay_due_expenses

    if player.money < 0
      puts 'you lose'
      exit
    end

    team.each(&:set_schedule)
    shop.generate
    self.next_opponent = nil
  end

  def do_activity(character)
    task = character.schedule[calendar.hour]
    task = %i[sleep free work train rest].sample if task == :out

    case task
    when :sleep
      character.recover(house.sleep.increment) unless character.health >= house.sleep.cap
    when :free
      character.recover(house.free.increment) unless character.health >= house.free.cap
      character.charge_focus(house.free.increment) unless character.focus >= house.free.cap
    when :work
      player.money += house.work.increment unless player.money >= house.work.cap
    when :train
      character.focus += house.train.increment unless character.focus >= house.train.cap
    when :rest
      character.health += house.rest.increment unless character.health >= house.rest.cap
    else
      raise "Activity not accounted for: #{task}"
    end

    notify "#{character.name} #{notify_activity(task)}"
  end

  def notify_activity(task)
    case task
    when :sleep
      SLEEP_TEXT.sample
    when :free
      FREE_TEXT.sample
    when :work
      WORK_TEXT.sample
    when :train
      TRAINING_TEXT.sample
    when :rest
      REST_TEXT.sample
    else
      raise "Activity not accounted for: #{task}"
    end
  end
end
