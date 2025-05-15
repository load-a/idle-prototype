# frozen_string_literal: true

class House
  attr_accessor :free, :train, :rest, :sleep, :work, :subscriptions

  Boost = Struct.new(:increment, :cap)

  def initialize
    self.free = Boost.new(1, 70)
    self.train = Boost.new(2, 100)
    self.rest = Boost.new(2, 100)
    self.sleep = Boost.new(1, 200)
    self.work = Boost.new(1, 200)
    self.subscriptions = []
  end

  def to_s
    template = '%-10s -> +%-2i to %16s until %i'
    [
      format(template, 'Free Time', free.increment, 'HEALTH and FOCUS', free.cap),
      format(template, 'Training', train.increment, 'FOCUS', train.cap),
      format(template, 'Relaxation', rest.increment, 'HEALTH', rest.cap),
      format(template, 'Sleeping', sleep.increment, 'HEALTH', sleep.cap),
      format(template, 'Working', work.increment, 'Money', work.cap),
      "Subscriptions: #{subscriptions.map(&:name).join(', ')}"
    ].join("\n")
  end

  def upgrade(stat, type, amount)
    trait = send(stat).send(type)
    boost = trait + amount
    send(stat).send("#{type}=", boost)
  end
end
