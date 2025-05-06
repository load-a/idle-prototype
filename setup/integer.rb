# frozen_string_literal: true

class Integer
  def not_negative?
    self >= 0
  end

  def not_positive?
    self <= 0
  end
end
