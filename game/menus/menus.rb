# frozen_string_literal: true

require_relative 'time_menu'
require_relative 'challenge_menu'
require_relative 'expense_menu'
require_relative 'inventory_menu'

module Menus
  include TimeMenu
  include ChallengeMenu
  include ExpenseMenu
  include InventoryMenu 
end
