# frozen_string_literal: true

module GameShopping
  def show_shop_menu
    loop do
      Output.new_screen
      shop.show_selection

      category = Input.ask_option(%w[abilities consumables upgrades subscriptions], prompt: 'Choose a category')

      break if category == BLANK_RESPONSE

      purchase = purchase_item(category)

      next if purchase.nil?
    end
  end

  def purchase_item(category)
    Output.new_screen
    items = shop.show_category(category.line, player.money)
    selection = Input.ask_option(items.map(&:name), prompt: 'select an item')

    return nil if selection == BLANK_RESPONSE

    purchase = items[selection.index]

    return nil if purchase.cost > player.money

    if Input.confirm?("Purchase #{purchase.name} for $#{purchase.cost}?")
      notify "Purchased #{purchase.name} (-$#{purchase.cost})"
      player.money -= purchase.cost
      inventory.send(purchase.type) << purchase
      items.delete_at(selection.index)
    else
      notify 'Cancelled purchase'
    end

    purchase
  end
end
