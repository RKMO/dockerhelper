require 'rake/dsl_definition'

module Dockerhelper
  module Tasks
    extend ::Rake::DSL

    def self.init(config)
      build_tasks = [:pull, :prebuild, :docker_build, :repo_tag, :push]
      build_tasks << :'kube:gen_rc' if config.kubernetes?

      namespace :docker do
        namespace(config.environment) do
          desc 'Print config info'
          task :info do
            keys = %i(app_name git_root git_branch git_repo_url docker_repo
              docker_image docker_tag rev_length dockerfile
              docker_repo_tag_prefix environment kube_rc_template
              kube_rc_dest_dir kube_rc_version env_vars prebuild_command
              docker_repo_tag)
            key_values = Hash[keys.map { |k| [k, config.send(k)] }]
            max_key_length = keys.map(&:size).sort[-1]
            key_values.each do |key, value|
              puts sprintf("%#{max_key_length}s  %s\n", key, value)
            end
          end

          desc 'Prepare to build docker image'
          task :prebuild do
            Command.new(config.prebuild_command, label: 'prebuild').run if config.prebuild?
          end

          desc 'Build docker image'
          task :docker_build do
            config.docker.build(config.dockerfile, tag: config.docker_image)
          end

          desc 'Pull git repo'
          task :pull do
            config.git.clone(config.git_repo_url, config.git_branch)
          end

          desc 'Tag docker image'
          task :repo_tag do
            tag_full = "#{config.docker_repo}:#{config.docker_repo_tag}"
            config.docker.tag(config.docker_image, tag_full)
          end

          desc 'Push docker images to Docker Hub'
          task :push do
            config.docker.push(config.docker_repo, tag: config.docker_repo_tag)
          end

          desc 'Git clone, build image, and push image to Docker Hub'
          task :build => build_tasks

          if config.kubernetes?
            namespace :kube do
              desc 'Generate replication controller for the current build'
              task :gen_rc do
                config.kubernetes.write_replication_controller
                puts "Created replication-controller: #{config.kubernetes.replication_controller_filename}"
              end

              desc 'Get current replication controller version'
              task :current_rc do
                puts config.kubernetes.current_rc
              end

              desc 'Run replication controller rolling-update'
              task :rolling_update do
                config.kubernetes.rolling_update
              end

              desc 'Create replication controller'
              task :create_rc => [:gen_rc] do
                config.kubernetes.replication_controller_create
              end

              desc 'Delete replication controller (USE WITH CAUTION)'
              task :delete_rc do
                # TODO add "are you sure?" prompt
                config.kubernetes.replication_controller_delete
              end
            end
          end
        end
      end
    end
  end
end
