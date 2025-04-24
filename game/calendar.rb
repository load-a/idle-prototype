# frozen_string_literal: true

class Calendar
  attr_accessor :year, :month, :day, :hour

  def initialize
    self.year = 3019
    self.month = 1
    self.day = 1
    self.hour = 10
  end

  def hour_array
    Array.new(24) { |index| (index == hour ? '-> %02i:00' : '%02i:00') % index }
  end

  def advance_hour(amount = 1)
    amount.times do
      self.hour += 1

      if hour >= 24
        self.hour %= 24
        advance_day
      end
    end
  end

  def advance_day(amount = 1)
    amount.times do
      self.day += 1

      if day >= 29
        self.day %= 28
        advance_month
      end
    end
  end

  def advance_month(amount = 1)
    amount.times do
      self.month += 1

      if month >= 14
        self.month %= 13
        advance_year
      end
    end
  end

  def advance_year(amount = 1)
    amount.times do
      self.year += 1

      if year >= 3020
        # Check for win condition
        # End main game
      end
    end
  end

  def day_month
    format('%s, %s %s', day_of_the_week, months_of_the_year, day)
  end

  def time
    format('%02i:00', hour)
  end

  def date
    full_date
  end

  def full_date
    day_month + ' ~ ' + time
  end

  def slash_date
    format('%i/%02i/%02i', year, month, day)
  end

  def day_of_the_week(day_of_the_month = self.day)
    case day_of_the_month % 7
    when 0
      'Sunday'
    when 1
      'Moonday'
    when 2
      'Emberday'
    when 3
      'Washday'
    when 4
      'Gailday'
    when 5
      'Earthenday'
    when 6
      'Starday'
    end
  end

  def months_of_the_year(month = self.month)
    %w[Zember Monoa Duon Trips Qhad Pennet Hesset Sennah Ower Nowary Dezzer][month]
  end
end
