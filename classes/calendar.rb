# frozen_string_literal: true

class Calendar
  attr_accessor :year, :month, :day, :hour

  DAYS_OF_THE_WEEK = %w[Sunday Moonday Emberday Washday Gailday Earthday Starday]
  MONTHS_OF_THE_YEAR = %w[Zember Monoa Duon Trips Qhad Pennet Hesset Sennah Ower Nowary Dezzer]

  def initialize
    self.year = 3025
    self.month = 1
    self.day = 1
    self.hour = 10
  end

  def serialize_date(year: self.year, month: self.month, day: self.day)
    '%04i%02i%02i' % [year, month, day]
  end

  def deserialize_date(date)
    '%i/%i/%i' % [date[0...4], date[4...6], date[6...8]]
  end

  def add_to_date(date, year: 0, month: 0, day: 0)
    y = date[0...4].to_i + year
    m = date[4...6].to_i + month
    d = date[6...8].to_i + day

    serialize_date(year: y, month: m, day: d)
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
    DAYS_OF_THE_WEEK[day_of_the_month % 7]
  end

  def months_of_the_year(month = self.month)
    MONTHS_OF_THE_YEAR[month - 1]
  end
end
