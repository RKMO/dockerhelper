module Dockerhelper
  class Docker
    attr_reader :chdir

    def initialize(chdir: Dir.pwd)
      @chdir = chdir
    end

    def tag(image, tag)
      Command.new("docker tag -f #{image} #{tag}", label: 'docker-tag').run
    end

    def build(dockerfile, tag: nil)
      tag || (raise 'Tag option is required')
      Command.new("docker build -t #{tag} -f #{dockerfile} .", label: 'docker-build', chdir: chdir).run
    end

    def push(repo, tag: 'latest')
      Command.new("docker push #{repo}:#{tag}", label: 'docker-build').run
    end
  end
end
