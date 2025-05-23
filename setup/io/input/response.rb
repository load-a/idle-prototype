# frozen_string_literal: true

class Response
  DEFAULT = '<???>'

  attr_accessor :raw, :line, :index

  def initialize(raw, index: 0)
    self.raw = raw
    self.line = clean.downcase
    self.index = index
  end

  def clean
    raw.strip
  end

  def character
    line[0]
  end

  def number
    line.to_i
  end

  def digit
    number.abs.to_s[0].to_i
  end

  def blank?
    self == BLANK_RESPONSE
  end
end
