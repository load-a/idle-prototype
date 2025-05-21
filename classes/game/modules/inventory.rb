# frozen_string_literal: true

module GameInventory
  Selection = Struct.new(:object, :index)
  NO_SELECTION = Selection.new(nil, nil)

  def inventory_screen
    Output.new_screen
    inventory.show_items
    inventory_action
  end

  def inventory_action
    action = Input.ask_option(%w[give upgrade stash trash], prompt: 'Pick an action: ')

    return unless %w[g u s t].include?(action.character)

    case action.index
    when 0 # Give
      puts 'Give Item'
      give_item
    when 1 # Use
      use_upgrade
    when 2 # Stash
      puts 'Store item'
      stash_item
    when 3 # Trash
      puts 'Delete item'
      trash_item
    end
  end

  def select_category
    category_id = Input.ask_option(inventory.item_hash.keys.map(&:to_s)).line.to_sym
    category_array = inventory.send(category_id)

    Selection.new(category_array, category_id)
  rescue NoMethodError
    NO_SELECTION
  end

  def use_upgrade
    # return if empty
    return if inventory.upgrades.empty?

    # Select item
    item_selection = select_item_from_inventory(Selection.new(inventory.upgrades, :upgrades))
    return if item_selection == NO_SELECTION

    # Select character
    character_selection = select_character
    return inventory.take(item_selection.object) if character_selection == NO_SELECTION

    stat = select_stat
    Upgrades.send(item_selection.object.id, character_selection.object, stat.object)
  end

  def give_item
    # return if empty
    category_selection = select_category
    return if category_selection == NO_SELECTION

    # Select item
    item_selection = select_item_from_inventory(category_selection)
    return if item_selection == NO_SELECTION

    # Select character
    character_selection = select_character
    return inventory.take(item_selection.object) if character_selection == NO_SELECTION

    # Select slot
    trait_selection = select_trait(character_selection)
    return inventory.take(item_selection.object) if trait_selection == NO_SELECTION

    # Give item
    replace_item(character_selection, trait_selection, item_selection)
  end

  def stash_item
    character_selection = select_character
    return if character_selection == NO_SELECTION

    trait_selection = select_trait(character_selection)
    return if trait_selection == NO_SELECTION

    unequip_item(character_selection, trait_selection)
  end

  def trash_item
    category_selection = select_category
    return if category_selection == NO_SELECTION

    item_selection = select_item_from_inventory(category_selection)
    return if item_selection == NO_SELECTION

    unless Input.confirm?("Throw #{item_selection.object.name} away? This can't be undone.")
      return inventory.take(item_selection.object)
    end

    log << "Threw #{item_selection.object.name} away."
  end

  def select_item_from_inventory(category_selection)
    category_id = category_selection.index

    inventory.list(category_id, display: true)
    item_index = Input.ask_number('Enter item number: ') - 1

    return NO_SELECTION unless (0...category_selection.object.length).include? item_index

    item = inventory.remove(category_id, item_index)

    Selection.new(item, item_index)
  end

  def select_character
    character_pick = Input.ask_option(player.team.members.map(&:name), prompt: 'Which character: ')
    character = player.team.members.select { |member| member.name.downcase == character_pick.line }[0]

    return NO_SELECTION if character.nil?

    Selection.new(character, character_pick.index)
  end

  def select_trait(character_selection)
    character = character_selection.object
    trait_index = Input.ask_option(character.traits.values.map(&:name), prompt: 'Which slot: ').index

    return NO_SELECTION unless (0..3).include? trait_index

    Selection.new(character.traits.keys[trait_index], trait_index)
  end

  def select_stat
    stat = Input.ask_option(%w[health power speed focus], prompt: 'Which stat: ')

    return NO_SELECTION unless (0..3).include? stat.index

    Selection.new(stat.text, stat.index)
  end

  def replace_item(character_selection, trait_selection, item_selection)
    if character_selection.object.traits[trait_selection.object] != NO_ITEM
      unequip_item(character_selection, trait_selection)
    end

    equip_item(character_selection, trait_selection, item_selection)
  end

  def unequip_item(character_selection, trait_selection)
    removed_item = character_selection.object.traits[trait_selection.object]
    return if removed_item == NO_ITEM

    character_selection.object.traits[trait_selection.object] = NO_ITEM
    inventory.take(removed_item)

    log << "#{character_selection.object.name} put #{removed_item.name} in inventory."
  end

  def equip_item(character_selection, trait_selection, item_selection)
    character_selection.object.traits[trait_selection.object] = item_selection.object
    log << "#{character_selection.object.name} set #{item_selection.object.name} as their #{trait_selection.object}."
  end
end
