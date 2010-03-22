require 'rubygems'

Gem::Specification.new do |s|
  s.platform  = Gem::Platform::RUBY
  s.name      = "boxgrinder-core"
  s.version   = "0.0.2"
  s.author    = "BoxGrinder Project"
  s.homepage  = "http://www.jboss.org/stormgrind/projects/boxgrinder.html"
  s.email     = "info@boxgrinder.org"
  s.summary   = "BoxGrinder Core files"
  s.files     = Dir['lib/**/*.rb'] << 'README' << 'LICENSE'
end
