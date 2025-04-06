# frozen_string_literal: true

class Calendar
  attr_accessor :year, :month, :day, :time

  def initialize()
    self.year, self.month, self.day, self.time = [3019, 1, 1, 10]
  end

  def advance_hour(amount = 1)
    amount.times do 
      self.time += 1

      if time >= 24
        self.time %= 24
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

  def date
    '%s, %s %i %02i:00 ~ %i/%02i/%02i' % [day_of_the_week, months_of_the_year, day, time, year, month, day]
  end

  def formal_date
    '%s, %s %i %02i:00' % [day_of_the_week, months_of_the_year, day, time, year, month, day]
  end

  def brief_date
    '%02i:00 ~ %i/%02i/%02i' % [time, year, month, day]
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

  def time_has_passed?(check_time)
    check_time < time
  end
end
