Gem::Specification.new do |s|
  s.name        = "quest-rb"
  s.version     = "0.2.7"
  s.summary     = "Quest Labs API Client"
  s.description = "Quest Labs API Client"
  s.authors     = ["Saul Moncada"]
  s.email       = ""
  s.files       = Dir['lib/**/*.rb']
  s.license     = "Unlicense"

  s.add_dependency "ruby-hl7", '~> 1.3.3', '<= 1.3.3'

  s.add_development_dependency "bundler", ">= 2.0"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
end
