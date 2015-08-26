require "bundler/gem_tasks"

desc 'Inline update the version file'
task :version, [:version] do |t, args|
  version = args[:version]
  fail "Error: Version not set\nUsage: rake version[x.y.z]" unless version
  fail "Error: Version should be x.y.z format" unless version =~ /\d+\.\d+\.\d+/
  version_file = File.expand_path('../lib/dockerhelper/version.rb', __FILE__)
  status = system(%~sed -i -e "s/^  VERSION.*/  VERSION = '#{version}'/" #{version_file}~)
  fail "Update version failed" unless status
end
