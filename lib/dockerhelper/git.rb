require 'fileutils'

module Dockerhelper
  class Git
    attr_reader :git_root, :rev_length

    def initialize(git_root, rev_length: 8)
      @git_root = git_root
      @rev_length = rev_length
      FileUtils.mkdir_p(git_root)
    end

    def clone(git_repo_url, branch)
      check_file = File.join(git_root, '.git')
      if File.exist?(check_file)
        Command.new("git fetch --depth=1 origin #{branch}", label: 'git-fetch', chdir: git_root).run
        Command.new("git checkout FETCH_HEAD", label: 'git-pull', chdir: git_root).run
      else
        Command.new("git clone --depth=1 --branch #{branch} #{git_repo_url} #{git_root}",
          label: 'git-clone', chdir: git_root).run
      end
    end

    def rev_list(max_count: 1, rev: 'FETCH_HEAD')
      cmd = "git rev-list --max-count=#{max_count} #{rev}"
      Command.new(cmd, label: 'git-rev-list', chdir: git_root).capture
    end

    def latest_rev
      rev_list[0...rev_length]
    end
  end
end
