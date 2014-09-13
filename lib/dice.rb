require "cheetah"
require "gli"
require "pathname"
require "fileutils"
require "digest"
require "find"

require_relative "constants"
require_relative "recipe"
require_relative "run_command"
require_relative "version"
require_relative "exceptions"
require_relative "cli"
require_relative "build_system"
require_relative "vagrant_build_system"
require_relative "host_build_system"
require_relative "job"
require_relative "solver"
require_relative "build_status"
require_relative "states"
require_relative "logger"
require_relative "build_task"
require_relative "diceconfig"

module Dice
  @config = DiceConfig.new

  def self.config
    @config
  end

  def self.configure
    yield @config
  end
end
