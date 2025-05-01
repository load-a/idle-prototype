# frozen_string_literal: true

module InventoryMenu
  def inventory_screen
    header = Output.columns(%w[Abilities Consumables Upgrades], content_just: :center, left_edge: '|', right_div: '|')
    divider = header.join.gsub(/\w|\s/, '-')
    system 'clear'

    puts header, divider
    puts Output.columns(inventory.values.map{|list| list.map(&:inventory_line)}, left_edge: '|', right_div: '|')
    puts divider.gsub('-', '_')
  end
end
