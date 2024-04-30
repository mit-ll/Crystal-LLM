class Mgrs::Latlon
  attr_accessor :convergence, :scale
  attr_reader :latitude, :longitude
  
  def initialize(lat, lon)
    @latitude = lat
    @longitude = lon
    @hemisphere = (lat >= 0) ? 'N' : 'S'
  end
  
  def to_utm
    falseEasting = 500e3
    falseNorthing = 100000e3
    zone = ((@longitude +180)/6).floor + 1
    lamda0 = ((zone-1)*6 -180 +3)/180.0 * Math::PI

    # ---- handle Norway/Svalbard exceptions
    arr = norway_svalbard_exceptions(zone, lamda0)
    zone = arr.shift
    lamda0 = arr.shift
    
    phi = @latitude.to_f/180.0 * Math::PI
    _lamda = @longitude.to_f/180.0 * Math::PI - lamda0
    
    # WGS 84:  a = 6378137, b = 6356752.314245, f = 1/298.257223563
    a = 6378137
    f = 1/298.257223563
    k0 = 0.9996
    
    arr = karney(a, f, phi, _lamda, k0)
    x = arr.shift
    y = arr.shift
    k = arr.shift
    gamma = arr.shift
    
    x = x + falseEasting
    y = y + falseNorthing if y < 0
    x = x.round(6)
    y = y.round(6)
    convergence = rad_to_degrees(gamma, 9)
    scale = k.round(12)
    hemisphere = (@latitude >= 0) ? 'N' : 'S'
    
    Mgrs::Utm.new(zone, hemisphere, x, y, convergence, scale)
  end
  
  def distance_to(lat, lon)
    # WGS 84:  a = 6378137, b = 6356752.314245, f = 1/298.257223563
    a = 6378137 # WGS84 a semi-major axis in meters
    haversine(a, lat, lon)   
  end  
  
  private
    def haversine(r, lat, lon)
      phi_us = degrees_to_rad(@latitude, nil)
      phi_to = degrees_to_rad(lat, nil)
      delta_phi = degrees_to_rad((lat - @latitude), nil)
      delta_lambda = degrees_to_rad((lon - @longitude),nil)
      a = (Math.sin(delta_phi/2) * Math.sin(delta_phi/2)) + (Math.cos(phi_us) * Math.cos(phi_to) * Math.sin(delta_lambda/2) * Math.sin(delta_lambda/2))
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      r * c
    end
    
    def karney(a, f, phi, _lamda, k0)
      # ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:
      e = Math.sqrt(f*(2 -f))
      n = f/(2 - f)
      n_squares = squares(n,5)
      
      coslamda = Math.cos(_lamda)
      sinlamda = Math.sin(_lamda)
      tanlamda = Math.tan(_lamda)
      tau = Math.tan(phi)
      sigma = Math.sinh(e * Math.atanh(e * tau/ Math.sqrt(1 + (tau * tau))))
      tau_prime = (tau * Math.sqrt( 1 + (sigma * sigma))) - (sigma * Math.sqrt(1 + (tau * tau)))
      xi_prime = Math.atan2(tau_prime, coslamda)
      eta_prime = Math.asinh(sinlamda / Math.sqrt((tau_prime * tau_prime) +(coslamda * coslamda)))
      alpha = a/(1+n) * (1 + (1.0/4.0 *n_squares[1]) + (1.0/64.0 *n_squares[3]) + (1.0/256.0 *n_squares[5]))
      
      beta = [nil]
      beta << (1.0/2.0 *n) - (2.0/3.0 *n_squares[1]) + (5.0/16.0 *n_squares[2]) + (41.0/180.0 *n_squares[3]) - (127.0/288.0 *n_squares[4]) + (7891.0/37800.0 *n_squares[5])
      beta << (13.0 /48.0 *n_squares[1]) - (3.0/5.0 *n_squares[2]) + (557.0/1440.0 *n_squares[3]) + (281.0/630.0 *n_squares[4]) - (1983433.0/1935360.0 *n_squares[5])
      beta << (61.0/240.0 *n_squares[2]) - (103.0/140.0 *n_squares[3]) + (15061.0/26880.0 *n_squares[4]) + (167603.0/181440.0 *n_squares[5])
      beta << (49561.0/161280.0 *n_squares[3]) - (179.0/168.0 *n_squares[4]) + (6601661.0/7257600.0 *n_squares[5])
      beta << (34729.0/80640.0 *n_squares[4]) - (3418889.0/1995840.0 *n_squares[5])
      beta << (212378941.0 /319334400.0 *n_squares[5])

      xi = xi_prime
      (1..6).each do |j|
        xi += beta[j] * Math.sin(2*j*xi_prime) * Math.cosh(2*j*eta_prime)
      end

      eta = eta_prime
      (1..6).each do |j|
        eta_prime += beta[j] * Math.cos(2*j*xi_prime) * Math.sinh(2*j*eta_prime)
      end

      x = k0 * alpha * eta
      y = k0 * alpha * xi

      #---- convergence: Karney 2011 Eq 23, 24
      p_prime = 1
      (1..6).each do |j|
        p_prime += 2 * j * beta[j] * Math.cos(2 * j * xi_prime) * Math.cosh(2 * j * eta_prime)
      end
      q_prime = 0
      (1..6).each do |j|
        q_prime += 2 * j * beta[j] * Math.sin(2 * j * xi_prime) * Math.sinh(2 * j * eta_prime)
      end
      gamma_prime = Math.atan(tau_prime/ Math.sqrt(1 + (tau_prime * tau_prime)))
      gamma_prime2 = Math.atan2(q_prime, p_prime)
      gamma = gamma_prime + gamma_prime2
      
      #---- scale: Karney 2011 Eq 25
      sinphi = Math.sin(phi)
      k_prime = Math.sqrt(1 - (e * e * sinphi * sinphi)) * Math.sqrt(1 + (tau * tau))/ Math.sqrt((tau_prime * tau_prime) + (coslamda * coslamda))
      k_prime2 = alpha / a * Math.sqrt((p_prime * p_prime) + (q_prime * q_prime))
      k = k0 * k_prime * k_prime2
      
      [x, y, k, gamma]
    end
    
    def norway_svalbard_exceptions(zone, lamda0)
      latBands = 'CDEFGHJKLMNPQRSTUVWXX' # X is repeated for 80-84°N
			latBand = latBands[(@latitude/8 + 10).floor]
			if zone == 31 && latBand =='V' && @utm_lon >= 3
				zone += 1
				lamda0 += 6.0/180.0 * Math::PI
			end
			if zone == 32 && latBand =='X' && @utm_lon < 9
			  zone -= 1
				lamda0 -= 6.0/180.0 * Math::PI
			end
			if zone == 32 && latBand =='X' && @utm_lon >= 9
				zone += 1
				lamda0 += 6.0/180.0 * Math::PI
			end
			if zone == 34 && latBand =='X' && @utm_lon < 21
			  zone -= 1
				lamda0 -= 6.0/180.0 * Math::PI
			end
			if zone == 34 && latBand =='X' && @utm_lon >= 21
				zone += 1
				lamda0 += 6.0/180.0 * Math::PI
			end
			if zone == 36 && latBand =='X' && @utm_lon < 33
			  zone -= 1
				lamda0 -= 6.0/180.0 * Math::PI
			end
			if zone == 36 && latBand =='X' && @utm_lon >= 33
				zone += 1
				lamda0 += 6.0/180.0 * Math::PI
			end
			[zone, lamda0]
    end
    
    def squares(n, ct)
      arr = []
      arr << n
      (1..ct).each do
        arr << (arr.last * n)
      end
      arr
    end
    
    def degrees_to_rad(n, precision)
      val = n * Math::PI / 180.0
      return val if precision.nil?
      val.round(precision)
    end
    
    def rad_to_degrees(n, precision)
      val = n * Math::PI / 180.0
      return val if precision.nil?
      val.round(precision)
    end
end
