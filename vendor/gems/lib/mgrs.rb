class Mgrs
  attr_accessor :zone, :band, :e100k, :n100k, :easting, :northing, :short_name
  
  LatBands = 'CDEFGHJKLMNPQRSTUVWXX' # X is repeated for 80-84°N
  E100kLetters = [ 'ABCDEFGH', 'JKLMNPQR', 'STUVWXYZ' ]
  N100kLetters = ['ABCDEFGHJKLMNPQRSTUV', 'FGHJKLMNPQRSTUVABCDE']
  
  # Implements validity check for military grid reference system string
  #
  # Example:
  #   >> Mgrs.valid?('4QFJ')
  #   => true
  #  
  #  Arguments:
  #    input: (String)
  
  def self.valid?(str)
    parsed = Parser.new(str)
    parsed.valid?
  end
  
  def self.to_latlon(str)
    parsed = Parser.new(str)
    return nil if !parsed.valid?
    obj = Converter.new(parsed)
    u = obj.to_utm
    ll = u.to_latlon
    {latitude: ll.latitude, longitude: ll.longitude }
  end
  
  def self.from_latlon(lat, lon)
    u = Mgrs::Latlon.new(lat, lon).to_utm
    u.to_mgrs
  end
  
  def to_s
    "#{@zone}#{@band}#{@e100k}#{@n100k}#{@easting}#{@northing}"
  end
  
  def initialize(str)
    if str.is_a?(Hash)
      @zone = str[:zone]
      @band = str[:band]
      @e100k = str[:e100k]
      @n100k = str[:n100k]
      @easting = str[:easting]
      @northing = str[:northing]
      @valid = true
    else
			parsed = Parser.new(str)
			@zone = parsed.zone
			@band = parsed.band
			@e100k = parsed.e100k
			@n100k = parsed.n100k
			@easting = parsed.easting
			@northing = parsed.northing
			@valid = parsed.valid?
      update_shortname if @valid
      update_latlon if @valid
    end
  end
  
  def center!
    ea = accuracy_digit(@easting)
    na = accuracy_digit(@northing)
    if (ea > na)
      @easting = @easting.insert(ea + 1, '5').slice(0,5) unless ea.nil? || ea == 4
      @northing = @northing.insert(ea + 1, '5').slice(0,5) unless ea.nil? || ea == 4
    elsif (na > ea)
      @easting = @easting.insert(na + 1, '5').slice(0,5) unless na.nil? || na == 4
      @northing = @northing.insert(na + 1, '5').slice(0,5) unless na.nil? || na == 4
    else
      @easting = @easting.insert(ea + 1, '5').slice(0,5) unless ea.nil? || ea == 4
      @northing = @northing.insert(na + 1, '5').slice(0,5) unless na.nil? || na == 4
    end
    update_shortname
    update_latlon
  end
  
  def center
    grid = self.dup
    grid.center!
    grid
  end
  
  def valid?
    @valid
  end
  
  def latitude
    update_latlon if (@latitude.nil?)
    @latitude
  end
  
  def longitude
    update_latlon if (@longitude.nil?)
    @longitude
  end
  
  def to_latlon
    parsed = Parser.new(self.to_s)
    obj = Converter.new(parsed)
    u = obj.to_utm
    ll = u.to_latlon
    {latitude: ll.latitude, longitude: ll.longitude }
  end
  
  def distance_to(mgrs)
    return nil unless mgrs.respond_to?(:to_latlon)
    us = self.to_latlon
    latlon = Mgrs::Latlon.new(us[:latitude], us[:longitude])
    them = mgrs.to_latlon
    m = latlon.distance_to(them[:latitude], them[:longitude])
    "#{(m/1000.0).round(3)} km"
  end
  
  private
  
  def accuracy_digit(str)
    (-1).downto(-5).each do |i|  
     r = str.index(/[1-9]/,i)
     return r unless r.nil?
    end
    -1
  end
  
  def update_shortname
    ea = accuracy_digit(@easting)
    na = accuracy_digit(@northing)
    easting = ''
    northing = ''
    if (ea > na)
      easting = @easting.slice(0, ea + 1)
      northing = @northing.slice(0, ea + 1)
    elsif (na > ea)
      easting = @easting.slice(0, na + 1)
      northing = @northing.slice(0, na + 1)
    elsif (ea > -1)
      easting = @easting.slice(0, ea + 1)
      northing = @northing.slice(0, ea + 1)
    end
    @short_name = "#{@zone}#{@band}#{@e100k}#{@n100k}#{easting}#{northing}"
  end
  
  def update_latlon
    ll = self.to_latlon
    @latitude = ll[:latitude]
    @longitude = ll[:longitude]
  end
  
end

require 'mgrs/converter'
require 'mgrs/utm'
require 'mgrs/parser'