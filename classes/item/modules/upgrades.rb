# frozen_string_literal: true

module Upgrades
  module_function

  def one_up(character, stat)
    character.upgrade_stat(stat, 1)
  end

  def two_up(character, stat)
    character.upgrade_stat(stat, 2)
  end

  def three_up(character, stat)
    character.upgrade_stat(stat, 3)
  end

  def one_down(character, stat)
    character.upgrade_stat(stat, -1)
  end

  def two_down(character, stat)
    character.upgrade_stat(stat, -2)
  end

  def three_down(character, stat)
    character.upgrade_stat(stat, -3)
  end
end
