require 'rake/dsl_definition'

module Dockerhelper
  module Tasks
    extend ::Rake::DSL

    def self.init(config, environment: :production)
      namespace :docker do
        namespace(environment) do

          desc 'Print config info'
          task :info do
            puts config.inspect
          end

          desc 'Build docker image'
          task :build do
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
          task :deploy => [:pull, :build, :repo_tag, :push]
        end
      end
    end
  end
end

