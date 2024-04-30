class Mgrs::Parser
  attr_accessor :zone, :band, :e100k, :n100k, :easting, :northing
  
  def initialize(str)
    @valid = false
    m = /\A([1-5][0-9]|60|[1-9])([C-H,J-N,P-X])([A-H,J-N,P-X])([A-H,J-N,P-V])(\d{0,10}){0,1}\Z/.match(str)
    unless m.nil? || m.size == 5
      m = nil if m[5].size % 2 == 1
    end
    unless m.nil?
      @zone = m[1]
      @band = m[2]
      @e100k = m[3]
      @n100k = m[4]
      if m[5].empty?
        @easting = '00000'
        @northing = '00000'
      else
        n = m[5].size/2
        east = m[5].slice(0,n)
        north = m[5].slice(n,n)
        @easting = (east + '00000').slice(0,5)
        @northing = (north + '00000').slice(0,5)
      end
      @valid = is_valid?
    end
  end
  
  def valid?
    @valid
  end
  
  private
  
  def is_valid?
    return false if Mgrs::E100kLetters[(@zone.to_i - 1) % 3].index(@e100k).nil?
    return false if Mgrs::N100kLetters[(@zone.to_i - 1) % 2].index(@n100k).nil?
    true
  end
end