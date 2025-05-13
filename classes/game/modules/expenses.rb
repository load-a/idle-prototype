# frozen_string_literal: true

module GameExpenses
  def expense_menu
    perform_list_maintenence
    due_dates = expenses.map(&:next_due).uniq

    Output.new_screen("Expense Report".center(120), ('-' * 120))

    due_dates.each do |date|
      dates_expenses = expenses.select {|expense| expense.next_due == date}
      total = format("\tTotal................$%4i.00", dates_expenses.map(&:cost).sum)

      puts calendar.deserialize_date(date)
      dates_expenses.each {|expense| puts "\t#{expense.to_s}"}
      puts Rainbow(total).italic
    end

    Input.ask_keypress
  end

  def initialize_expenses
    rent_day = calendar.serialize_date
    rent_day = calendar.add_to_date(rent_day, month: 1)
    self.expenses = [Expense.new('Rent', 'Apartment Rent', 400, :monthly, rent_day)]

    first_daily_due_date = calendar.add_to_date(calendar.serialize_date, day: 1)

    player.team.members.each do |member|
      expenses << Expense.new("#{member.name}", 'Daily living expenses', 40, :daily, first_daily_due_date)
    end
  end

  def set_next_due_date(expense)
    expense.next_due = case expense.type
                       when :daily
                         calendar.add_to_date(expense.next_due, day: 1)
                       when :weekly
                         calendar.add_to_date(expense.next_due, day: 7)
                       when :monthly
                         calendar.add_to_date(expense.next_due, month: 1)
                       else
                         0
                       end
  end

  def pay_due_expenses
    due_expenses = expenses.select {|expense| expense.next_due == calendar.serialize_date}

    due_expenses.each do |expense| 
      player.money -= expense.cost 
      notify "Paid $#{expense.cost} to #{expense.name} (#{expense.type})"
      set_next_due_date(expense)
    end
  end

  def perform_list_maintenence
    expenses.delete_if {|expense| expense.next_due.to_i < calendar.serialize_date.to_i}
    expenses.sort_by! {|expense| expense.next_due.to_i}
  end
end
