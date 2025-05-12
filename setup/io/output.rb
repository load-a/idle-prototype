# frozen_string_literal: true

module Output
  module_function

  SCHEDULE_TEMPLATE = '%s%02i:00 - %s'

  def show_schedule
    times = [
      "#{player.name}'s Schedule for #{calendar.day_of_the_week}, #{calendar.months_of_the_year} #{calendar.day}",
      "Current Action: #{player.schedule[calendar.hour]}"
    ]

    player.schedule.each_with_index do |activity, hour|
      times << format(SCHEDULE_TEMPLATE, calendar.hour == hour ? '-> ' : '   ', hour, activity)
    end

    times
  end

  def numbered_list(array)
    list = []

    array.each_with_index do |element, index|
      list << format('%i. %s', index + 1, element)
    end

    list
  end

  def columns(texts, row_headers: nil, left_div: '', right_div: '', right_edge: '', left_edge: '', header_just: :ljust,
              content_just: :ljust)
    texts = [texts] unless texts.is_a? Array
    row_headers = [row_headers] unless row_headers.nil? || row_headers.is_a?(Array)
    elements = texts.length

    output = []
    row = 0

    ornament_widths = (elements * (right_div.length + left_div.length)) + right_edge.length + left_edge.length
    header_width = row_headers.nil? ? 0 : row_headers.map(&:length).max

    row_width = 120 - ornament_widths - header_width

    width = row_width / texts.length

    texts.map! do |element|
      element.is_a?(Array) ? element : [element]
    end

    length = texts.map(&:length).max

    length.times do
      line = ''
      texts.each { |text| line += left_div + "#{text[row]}".send(content_just, width) + right_div }
      line += right_edge
      output << line
      row += 1
    end

    return output.map { |line| left_edge + line } if header_width.zero?

    row = -1

    output.map! do |line|
      row += 1
      left_edge + "#{row_headers[row]}".send(header_just, header_width) + line
    end

    output
  end

  def four_stat_screen(title, team)
    raise ArgumentError.new("Four Stat Screen's first parameter must be a Team object") unless team.is_a? Team

    output = []
    output << title.center(120)

    list = team.members.map(&:attribute_chart).map(&:values)

    columns(list)
  end
end
