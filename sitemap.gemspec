require File.expand_path('../lib/sitemap/version', __FILE__)

spec = Gem::Specification.new do |spec|
  spec.name = "sitemap"
  spec.version = Sitemap::VERSION
  spec.summary = "Sitemap"
  spec.description = "A simple ruby on rails sitemap generator"

  spec.authors << "Daniel Mircea"
  spec.email = "daniel@viseztrance.com"
  spec.homepage = "http://github.com/viseztrance/rails-sitemap"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rails", ">= 3.0.0"
  spec.add_development_dependency "nokogiri"

  spec.files = Dir["{lib,docs}/**/*"] + ["README.md", "LICENSE", "Rakefile", "sitemap.gemspec"]
  spec.test_files = Dir["test/**/*"]
  spec.require_paths = ["lib"]

end
