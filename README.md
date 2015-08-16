# Dockerhelper

Helper classes and rake tasks to build Docker images, push them to DockerHub,
and deploy updates to Kubernetes. Assumes a rather specific workflow for
building Docker images and deploying them to Kubernetes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dockerhelper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dockerhelper

## Usage

Example usage in a `Rakefile`:

```ruby
require 'dockerhelper'
require 'dockerhelper/rake'

project_root = File.expand_path('../../', __FILE__)
config = Dockerhelper.configure do |c|
  c.app_name                = 'project'
  c.environment             = :production
  c.git_repo_url            = 'git@github.com:org/project.git'
  c.git_root                = File.join(project_root, 'tmp/repo')
  c.git_branch              = ENV['GIT_BRANCH'] || 'master'
  c.dockerfile              = 'docker/Dockerfile.production'
  c.docker_image            = 'project-image-name'
  c.docker_repo             = 'org/project'
  c.docker_repo_tag_prefix  = 'prd-'
  c.kube_rc_template        = File.expand_path('../project-rc.yml.erb', __FILE__)
  c.kube_rc_dest_dir        = File.dirname(__FILE__)
end

Dockerhelper::Tasks.init(config)
```

The above will define rake tasks, for example:

```
rake docker:production:build        # Build docker image
rake docker:production:deploy       # Git clone, build image, and push image to Docker Hub
rake docker:production:info         # Print config info
rake docker:production:kube:gen_rc  # Generate replication controller for the current build
rake docker:production:pull         # Pull git repo
rake docker:production:push         # Push docker images to Docker Hub
rake docker:production:repo_tag     # Tag docker image
```
