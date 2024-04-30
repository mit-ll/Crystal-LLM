require 'mgrs/latlon'

class Mgrs::Converter

  def initialize(parsed)
    @parser_obj = parsed
  end
  
  def to_utm
    zone = @parser_obj.zone
    band = @parser_obj.band
    hemisphere = @parser_obj.band >= 'N' ? 'N' : 'S'
    e100k = @parser_obj.e100k
    n100k = @parser_obj.n100k
    easting = @parser_obj.easting.to_i
    northing = @parser_obj.northing.to_i
    
#    latBands = 'CDEFGHJKLMNPQRSTUVWXX' # X is repeated for 80-84°N
#    e100kLetters = [ 'ABCDEFGH', 'JKLMNPQR', 'STUVWXYZ' ]
#    n100kLetters = ['ABCDEFGHJKLMNPQRSTUV', 'FGHJKLMNPQRSTUVABCDE']

    e100knum = (Mgrs::E100kLetters[(zone.to_i - 1) % 3].index(e100k) + 1) * 100000
    n100knum = (Mgrs::N100kLetters[(zone.to_i - 1) % 2].index(n100k)) * 100000
    
    latBand = (Mgrs::LatBands.index(band) -10) * 8
    nBand = Mgrs::Latlon.new(latBand, 0).to_utm.northing
    n2M = 0
    while (n2M + n100knum + northing < nBand)
      n2M += 2000000
    end
    Mgrs::Utm.new(zone, hemisphere, e100knum + easting, n2M + n100knum + northing)
  end
  
  
end

