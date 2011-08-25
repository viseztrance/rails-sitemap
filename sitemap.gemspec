spec = Gem::Specification.new do |spec|
  spec.name = "sitemap"
  spec.version = "0.0.1"
  spec.summary = "Sitemap"
  spec.description = "A simple ruby on rails sitemap generator"

  spec.authors << "Daniel Mircea"
  spec.email = "daniel@viseztrance.com"
  spec.homepage = "http://github.com/viseztrance/sitemap"

  spec.files = Dir["{bin,lib,docs}/**/*"] + ["README.rdoc", "LICENSE", "Rakefile", "sitemap.gemspec"]

  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README.rdoc" << "--title" <<  "Sitemap" << "--line-numbers"
                       "--webcvs" << "http://github.com/viseztrance/sitemap"
  spec.extra_rdoc_files = ["README.rdoc", "LICENSE"]
end
