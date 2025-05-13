# frozen_string_literal: true

class Expense
  attr_accessor :name, :description, :cost, :type, :next_due

  def initialize(name, description, cost, type, next_due = nil)
    self.name = name
    self.description = description
    self.cost = cost
    self.type = type
    self.next_due = next_due
  end

  def reduce_by(percentage)
    percentage /= 100.00 if percentage > 1
    discount = (cost * percent).round
    self.cost -= discount
  end

  def to_s
    '%-20s $%4i -- %-50s (%s)' % [name, cost, description, type]
  end
end
