
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aaq/version"

Gem::Specification.new do |spec|
  spec.name          = "aaq"
  spec.version       = AAQ::VERSION
  spec.authors       = ["yskoht"]
  spec.email         = ["ysk.oht@gmail.com"]

  spec.summary       = %q{Create ascii art quine from image file}
  spec.homepage      = "https://github.com/yskoht/aaq"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2.33"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.58"

  spec.add_dependency "rmagick", "~> 2.16"
end
