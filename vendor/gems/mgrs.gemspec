Gem::Specification.new do |s|
  s.name        = 'mgrs'
  s.version     = '0.2.4'
  s.date        = '2016-12-07'
  s.summary     = "Military grid reference system"
  s.description = "Ruby port of logic from MIT licensed javascript at: http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html"
  s.authors     = ["Thomas White"]
  s.email       = 'thomas.white@ll.mit.edu'
  s.files       = ["lib/mgrs.rb",  "lib/mgrs/parser.rb", "lib/mgrs/converter.rb" ,"lib/mgrs/latlon.rb", "lib/mgrs/utm.rb"]
  s.homepage    = 'http://rubygems.org/gems/mgrs'
  s.license     = 'MIT'
end