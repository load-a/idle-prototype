# frozen_string_literal: true

class House
  attr_accessor :free, :train, :rest, :sleep, :work

  Boost = Struct.new(:increment, :cap)

  def initialize
    self.free = Boost.new(1, 70)
    self.train = Boost.new(2, 100)
    self.rest = Boost.new(2, 100)
    self.sleep = Boost.new(1, 200)
    self.work = Boost.new(1, 200)
  end

  def to_s
    template = '%-10s -> +%-2i to %16s until %i'
    [
      template % ['Free Time', free.increment, 'HEALTH and FOCUS', free.cap],
      template % ['Training', train.increment, 'FOCUS', train.cap],
      template % ['Relaxation', rest.increment, 'HEALTH', rest.cap],
      template % ['Sleeping', sleep.increment, 'HEALTH', sleep.cap],
      template % ['Working', work.increment, 'Money', work.cap]
    ].join("\n")
  end

  def upgrade(stat, type, amount)
    trait = self.send(stat).send(type)
    boost = trait + amount
    self.send(stat).send("#{type}=", boost)
  end
end
