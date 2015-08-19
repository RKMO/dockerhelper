module Dockerhelper
  class Config
    attr_accessor :app_name
    attr_accessor :git_root
    attr_accessor :git_branch
    attr_accessor :git_repo_url
    attr_accessor :docker_repo
    attr_accessor :docker_image
    attr_accessor :docker_tag
    attr_accessor :rev_length
    attr_accessor :dockerfile
    attr_accessor :docker_repo_tag_prefix
    attr_accessor :environment
    attr_accessor :kube_rc_template
    attr_accessor :kube_rc_dest_dir
    attr_accessor :kube_rc_version
    attr_accessor :env_vars
    attr_accessor :prebuild_command

    def initialize
      # defaults
      @rev_length = 8
      @kube_rc_dest_dir = Dir.pwd
    end

    def git
      @git ||= Git.new(git_root, rev_length: rev_length)
    end

    def docker
      @docker ||= Docker.new(chdir: git_root)
    end

    def kubernetes?
      @kube_rc_template && @kube_rc_dest_dir
    end

    def kubernetes
      @kubernetes ||= Kubernetes.new(self)
    end

    def docker_repo_tag
      @docker_tag || "#{docker_repo_tag_prefix}#{git.latest_rev}"
    end

    def check_env_vars!
      return unless env_vars
      unless env_vars.respond_to?(:reject)
        raise ArgumentError.new('Expected an array of env_vars')
      end
      undefined = env_vars.reject(&ENV.method(:has_key?))
      unless undefined.empty?
        raise StandardError.new("The environment must define #{undefined.join ', '}")
      end
    end

    def prebuild?
      prebuild_command && !prebuild_command.empty?
    end
  end
end
