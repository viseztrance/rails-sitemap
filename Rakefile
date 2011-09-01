require "rake"
require "rdoc/task"
require "rake/testtask"

spec = Gem::Specification.load(File.expand_path("sitemap.gemspec", File.dirname(__FILE__)))

desc "Default: run sitemap unit tests."
task :default => :test

desc "Test the sitemap plugin."
Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

# Create the documentation.
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include "README.rdoc", "lib/**/*.rb"
  rdoc.options = spec.rdoc_options
end

desc "Push new release to rubyforge and git tag"
task :push do
  sh "git push"
  puts "Tagging version #{spec.version} .."
  sh "git tag v#{spec.version}"
  sh "git push --tag"
  puts "Building and pushing gem .."
  sh "gem build #{spec.name}.gemspec"
  sh "gem push #{spec.name}-#{spec.version}.gem"
end

desc "Install #{spec.name} locally"
task :install do
  sh "gem build #{spec.name}.gemspec"
  sh "gem install #{spec.name}-#{spec.version}.gem"
end
