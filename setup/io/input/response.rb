# frozen_string_literal: true

class Response
  DEFAULT = '<???>'

  attr_accessor :raw, :default, :index

  def initialize(raw, index: nil)
    self.raw = raw
    self.default = raw.strip.gsub(/\W/, '').empty?
    self.index = index
  end

  def text
    return DEFAULT if default

    raw.strip.downcase.gsub(/\W/, '')
  end

  def character
    return DEFAULT[1] if default

    text[0]
  end
  alias char character

  def number
    text.to_i
  end

  def [](*args)
    text.call('[]', args)
  end

  def number?
    text.to_i.to_s == text
  end

  def default?
    text == DEFAULT
  end
end
