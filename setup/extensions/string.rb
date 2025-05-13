# frozen_string_literal: true

class String
  def fill(character = ' ', length = self.length)
    return self if length < self.length

    filler_length = length - self.length

    "#{self}#{character * filler_length}"
  end

  def integer?
    to_i.to_s == self
  end
end
