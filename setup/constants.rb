# frozen_string_literal: true

NO_ITEM = Item.new(:none, :none, 0, 'No Item')
BLANK_RESPONSE = Response.new('', index: 0)

SPEED_MULTIPLIER = {
  '2' => 3.5,
  '4' => 3,
  '6' => 2.5,
  '8' => 2,
  '10' => 1.5,
  '12' => 1,
  '20' => 0.5
}.freeze
