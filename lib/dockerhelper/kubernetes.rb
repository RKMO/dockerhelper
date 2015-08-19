require 'erb'
require 'yaml'

module Dockerhelper
  class Kubernetes
    attr_reader :config
    def initialize(config)
      @config = config
    end

    def app_name
      config.app_name
    end

    def app_version
      config.kube_rc_version || config.docker_repo_tag
    end

    def app_full_name
      "#{app_name}-#{app_version}"
    end

    def current_rc
      out = Command.new("kubectl get rc -l app=#{app_name},environment=#{config.environment}",
        label: 'kubectl-get-rc').capture

      # assumes rc will be found
      out.lines[1].match(/^\S+/)[0]
    end

    def rolling_update
      Command.new("kubectl rolling-update #{current_rc} -f #{replication_controller_filename}",
        label: 'kubectl-get-rc').run
    end

    def replication_controller_create
      Command.new("kubectl create -f #{replication_controller_filename}",
        label: 'kubectl-create-rc').run
    end

    def replication_controller_delete
      Command.new("kubectl delete rc #{current_rc}", label: 'kubectl-delete-rc').run
    end

    def replication_controller_yaml
      yaml_in = File.read(config.kube_rc_template)
      ERB.new(yaml_in).result(binding)
    end

    def write_replication_controller
      File.write(replication_controller_filename, replication_controller_yaml)
    end

    def replication_controller_filename
      File.join(config.kube_rc_dest_dir, "#{app_full_name}-rc.yml")
    end
  end
end
