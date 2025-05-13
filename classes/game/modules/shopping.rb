# frozen_string_literal: true

module GameShopping
  def show_shop_menu
    loop do
      system 'clear'
      shop.show_selection

      category = Input.ask_option('abilities', 'consumables', 'upgrades', 'subscriptions', prompt: 'Choose a category')

      break if category == BLANK_RESPONSE

      purchase = purchase_item(category)

      next if purchase.nil?
    end
  end

  def purchase_item(category)
    system 'clear'
    items = shop.show_category(category.line, player.money) 
    selection = Input.ask_option(*items.map(&:name), prompt: 'select an item')

    return nil if selection == BLANK_RESPONSE

    purchase = items[selection.index]

    return nil if purchase.cost > player.money

    if Input.confirm?("Purchase #{purchase.name} for $#{purchase.cost}?")
      log << "Purchased #{purchase.name} (-$#{purchase.cost})"
      inventory.send(purchase.type) << purchase
      items.delete_at(selection.index)
    else
      log << 'Cancelled purchase'
    end

    purchase
  end
end
