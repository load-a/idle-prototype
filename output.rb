# frozen_string_literal: true

class Screen
  attr_accessor :header_template, :content_template

  def initialize(header_template = '%s', content_template = '%s')
    self.header_template = header_template
    self.content_template = content_template
  end

  def show(header = '', content = '', spacer: '')
    content = [content] unless content.is_a? Array

    puts "#{header_template % header}#{spacer}"
    puts(*content.map { |value| "#{content_template % value}#{spacer}" })
  end
end

module Output
  module_function

  SCHEDULE_TEMPLATE = '%s%02i:00 - %s'

  def show_schedule
    times = [
      "#{player.name}'s Schedule for #{calendar.day_of_the_week}, #{calendar.months_of_the_year} #{calendar.day}",
      "Current Action: #{player.schedule[calendar.hour]}"
    ]

    player.schedule.each_with_index do |activity, hour|
      times << (format(SCHEDULE_TEMPLATE, (calendar.hour == hour ? '-> ' : '   '), hour, activity))
    end

    times
  end

  def numbered_list(array)
    list = []

    array.each_with_index do |element, index|
      list << (format('%i. %s', index + 1, element))
    end

    list
  end

  def columns(width, elements)
    output = []
    line = ''
    row = 0

    elements[0].length.times do
      elements.each do |element|
        line += "#{element[row]}".ljust(width) || ''
      end

      output << line
      line = ''
      row += 1
    end

    output
  end

  def four_stat_screen(title, team)
    raise ArgumentError.new("Four Stat Screen's first parameter must be a Team object") unless team.is_a? Team

    output = []
    output << title.center(120)

    list = team.members.map(&:attribute_chart).map(&:values)

    columns(30, list).each do |row|
      output << row
    end

    output
  end
end
