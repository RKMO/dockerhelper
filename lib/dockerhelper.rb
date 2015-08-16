require "dockerhelper/config"
require "dockerhelper/command"
require "dockerhelper/docker"
require "dockerhelper/git"
require "dockerhelper/kubernetes"
require "dockerhelper/version"

module Dockerhelper
  def cmd(cmd, label: '')
    Command.new(cmd, label: label).run
  end
  module_function :cmd

  def self.configure(&block)
    config = Config.new
    block.call(config)
    config
  end
end
