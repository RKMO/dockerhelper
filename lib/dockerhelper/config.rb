module Dockerhelper
  class Config
    attr_accessor :git_root
    attr_accessor :git_branch
    attr_accessor :git_repo_url
    attr_accessor :docker_repo
    attr_accessor :docker_image
    attr_accessor :docker_tag
    attr_accessor :rev_length
    attr_accessor :dockerfile
    attr_accessor :docker_repo_tag_prefix

    def initialize
      # defaults
      @rev_length = 8
    end

    def git
      @git ||= Git.new(git_root, rev_length: rev_length)
    end

    def docker
      @docker ||= Docker.new(chdir: git_root)
    end

    def docker_repo_tag
      @docker_tag || "#{docker_repo_tag_prefix}#{git.latest_rev}"
    end
  end
end
