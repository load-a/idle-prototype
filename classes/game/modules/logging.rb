# frozen_string_literal: true

module GameLogging
  MAIN_LOG_SIZE = 16

  def initialize_log
    self.log = Array.new(MAIN_LOG_SIZE, ' ')
    self.combat_log = []
  end

  def notify(text)
    log << text
    log.flatten!
    log.shift while log.size > MAIN_LOG_SIZE
  end
end
