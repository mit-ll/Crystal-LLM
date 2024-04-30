class Mgrs::Utm
  attr_reader :zone, :hemisphere, :easting, :northing 

  def initialize(zone, hemisphere, easting, northing, conv = nil, scale = nil)
    raise ArgumentError, 'Zone is NaN' if zone.to_f.nan?
    raise ArgumentError, 'Easting is NaN' if easting.to_f.nan?
    raise ArgumentError, 'Northing is NaN' if northing.to_f.nan?
    @zone = zone
    @hemisphere = hemisphere
    @easting = easting
    @northing = northing
    @converence = conv
    @scale = scale
  end
  
  def to_latlon
    z = @zone.to_i
    h = @hemisphere
    x = @easting
    y = @northing
    falseEasting = 500e3
    falseNorthing = 100000e3
    
    # WGS 84:  a = 6378137, b = 6356752.314245, f = 1/298.257223563
    a = 6378137
    b = 6356752.314245
    f = 1.0/298.257223563
    k0 = 0.9996
    
    x = x - falseEasting
    y = (h == 'S') ? y - falseNorthing : y
    
    karney_out =  karney(a, b, f, k0, x, y)
    _lamda = karney_out.shift
    phi = karney_out.shift
    gamma = karney_out.shift
    k = karney_out.shift
    
    lamda0 = degrees_to_rad((z-1)*6 - 180 + 3, 11)
    _lamda += lamda0
    lat = rad_to_degrees(phi, 11)
    lon = rad_to_degrees(_lamda, 11)
    convergence = rad_to_degrees(gamma, 9)
    scale = k.round(12)
    
    ll = Mgrs::Latlon.new(lat, lon)
    ll.convergence = convergence
    ll.scale = scale
    ll
  end
  
  def to_mgrs
    ll = to_latlon
    latband = Mgrs::LatBands[((ll.latitude / 8) +10).floor]
    col = (@easting / 100e3).floor - 1
    e100k = Mgrs::E100kLetters[(@zone.to_i - 1) % 3][col]
    row = (@northing / 100e3).floor % 20
    n100k = Mgrs::N100kLetters[(@zone.to_i - 1) % 2][row]
    new_easting = ("#{(@easting % 100e3).to_i}" + '00000').slice(0,5)
    new_northing = ("#{(@northing % 100e3).to_i}" + '00000').slice(0,5)
    Mgrs.new({zone: @zone, band: latband, e100k: e100k, n100k: n100k, easting: new_easting, northing: new_northing})
  end
  
  private
  
    def karney(a, b, f, k0, x, y)
      # ---- from Karney 2011 Eq 15-22, 36:
      e = Math.sqrt(f * (2 - f))
      n = f/(2 - f)
      n_squares = squares(n,5)
      alpha = a/(1+n) * (1 + (1.0/4.0 * n_squares[1]) + (1.0/64.0 * n_squares[3]) + (1.0/256.0 * n_squares[5]))
      eta = x/(k0 * alpha)
      xi = y/(k0 * alpha)
      
      beta = [nil]
      beta << (1.0/2.0 *n) - (2.0/3.0 *n_squares[1]) + (37.0/96.0 *n_squares[2]) - (1.0/360.0 *n_squares[3]) - (81.0/512.0 *n_squares[4]) + (96199.0/604800.0 *n_squares[5])
      beta << (1.0/48.0 *n_squares[1]) + (1.0/15.0 *n_squares[2]) - (437.0/1440.0*n_squares[3]) + (46.0/105.0 *n_squares[4]) - (1118711.0/3870720.0 *n_squares[5])
      beta << (17.0/480.0 *n_squares[2]) - (37.0/840.0 *n_squares[3]) - (209.0/4480.0 *n_squares[4]) + (5569.0/90720.0 *n_squares[5])
      beta << (4397.0/161280.0 *n_squares[3]) - (11.0/504.0 *n_squares[4]) - (830251.0/7257600.0 *n_squares[5])
      beta << (4583.0/161280.0 *n_squares[4]) - (108847.0/3991680.0 *n_squares[5])
      beta << (20648693.0/638668800.0 *n_squares[5])
      
      xi_prime = xi
      (1..6).each do |j|
        xi_prime -= beta[j] * Math.sin(2*j*xi) * Math.cosh(2*j*eta)
      end
      eta_prime = eta
      (1..6).each do |j|
        eta_prime -= beta[j] * Math.cos(2*j*xi) * Math.sinh(2*j*eta)
      end
      
      sinh_eta_prime = Math.sinh(eta_prime)
      sin_xi_prime = Math.sin(xi_prime)
      cos_xi_prime = Math.cos(xi_prime)
      tau_prime = sin_xi_prime / Math.sqrt((sinh_eta_prime * sinh_eta_prime) + (cos_xi_prime * cos_xi_prime))
      tau_i = tau_prime
      delta_tau_i  = nil
      loop do
        omicron_i = Math.sinh( e * Math.atanh( e * tau_i/ Math.sqrt(1 + (tau_i * tau_i)))) 
        tau_i_prime = (tau_i * Math.sqrt(1 + (omicron_i * omicron_i))) - (omicron_i * Math.sqrt(1 + (tau_i * tau_i)))
        delta_tau_i = (tau_prime - tau_i_prime) / Math.sqrt(1 + (tau_i_prime * tau_i_prime)) * 
        (1 + ( (1-(e * e)) * (tau_i * tau_i))) / ((1 -(e*e)) * Math.sqrt(1 + (tau_i * tau_i)))
        tau_i += delta_tau_i
        break if (delta_tau_i.abs <= 1e-12)
      end
      tau = tau_i
      phi = Math.atan(tau)
      _lamda = Math.atan2(sinh_eta_prime, cos_xi_prime)
      
      # ---- convergence: Karney 2011 Eq 26, 27
      p = 1
      (1..6).each do |j|
        p -= 2.0 * j * beta[j] * Math.cos(2.0 *j*xi) * Math.cosh(2.0 *j *eta)
      end
      q = 0
      (1..6).each do |j|
        q += 2.0 * j * beta[j] * Math.sin(2.0 *j*xi) * Math.sinh(2.0 *j *eta)
      end
      gamma_prime = Math.atan(Math.tan(xi_prime) * Math.tanh(eta_prime))
      gamma_prime2 = Math.atan2(q,p)
      gamma = gamma_prime + gamma_prime2
      
      # ---- scale: Karney 2011 Eq 28
      sin_phi = Math.sin(phi)
      k_prime = Math.sqrt(1 - (e * e * sin_phi * sin_phi)) * Math.sqrt(1 + (tau * tau)) * Math.sqrt((sinh_eta_prime * sinh_eta_prime) + (cos_xi_prime * cos_xi_prime))
      k_prime2 = alpha/a/Math.sqrt((p * p) + (q * q))
      k = k0 * k_prime * k_prime2
      
      # ----
      [_lamda, phi, gamma, k]
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
      val = n * 180 / Math::PI
      return val if precision.nil?
      val.round(precision)
    end
end