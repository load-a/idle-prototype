# frozen_string_literal: true

require_relative 'time'
require_relative 'challenges'
require_relative 'expenses'
require_relative 'inventory'
require_relative 'combat'
require_relative 'shopping'
require_relative 'logging'

module GameModules
  include GameTime
  include GameChallenges
  include GameExpenses
  include GameInventory 
  include GameCombat
  include GameInventory
  include GameShopping
  include GameLogging
end
