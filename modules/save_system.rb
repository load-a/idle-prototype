# frozen_string_literal: true

module SaveSystem
  module_function

  def save(game)
    save_file = File.read('game_data/save_data.json')

    if !save_file.empty?
      return unless Input.confirm?("Overwrite current save data?")
    end

    IO.write('game_data/save_data.json', JSON.pretty_generate(game.serialize))
  end

  def load(game)
    save_file = File.read('game_data/save_data.json')

    if save_file.empty?
      puts "No save data." 
      Input.ask_keypress
      return
    end

    return unless Input.confirm?("End current game and load Save Data? This cannot be undone.")

    data = JSON.parse(save_file)
    game.deserialize(data)
  end

  def delete_file; end
end
