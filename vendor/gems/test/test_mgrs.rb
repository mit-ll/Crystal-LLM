require 'minitest/autorun'
require 'mgrs'

class MgrsTest < Minitest::Test
  def test_good_grid_zone_only
    assert_equal true, Mgrs.valid?('4QFJ')
  end
  def test_61_grid_zone_only
    assert_equal false, Mgrs.valid?('61QFJ')
  end
  def test_I_grid_zone_only
    assert_equal false, Mgrs.valid?('4IAA')
  end
  def test_good_grid_zone_2
    assert_equal true, Mgrs.valid?('4FAA')
  end
  def test_O_grid_zone_only
    assert_equal false, Mgrs.valid?('4FOA')
  end
  def test_X_grid_zone_only
    assert_equal false, Mgrs.valid?('4FJX')
  end
  def test_good_grid_zone_plus_2
    assert_equal true, Mgrs.valid?('4FEG10')
  end
  def test_good_grid_zone_plus_3
    assert_equal false, Mgrs.valid?('4FEG101')
  end
  def test_good_grid_zone_plus_4
    assert_equal true, Mgrs.valid?('4FEF1014')
  end
  def test_good_grid_zone_plus_6
    assert_equal true, Mgrs.valid?('4FEF101465')
  end
  def test_good_grid_zone_plus_10
    assert_equal true, Mgrs.valid?('4FEG1014655647')
  end
  def test_good_grid_zone_plus_11
    assert_equal false, Mgrs.valid?('4FEG10146543212')
  end
  def test_good_grid_zone_plus_12
    assert_equal false, Mgrs.valid?('4FEG123456654321')
  end
  def test_good_grid_zone_above_boundary
    assert_equal false, Mgrs.valid?('61UDQ4825111932')
  end
  def test_good_grid_zone_60_boundary
    assert_equal true, Mgrs.valid?('60UUG4825111932')
  end
  def test_good_grid_zone_50_boundary
    assert_equal true, Mgrs.valid?('50UPG4825111932')
  end
  def test_good_grid_zone_20_boundary
    assert_equal true, Mgrs.valid?('20UPG4825111932')
  end
  
  def test_lat_long_conversion_1
    ll =  Mgrs.to_latlon('14TQM3092028750')
    assert_equal 41.777008, ll[:latitude].round(6)
    assert_equal -96.221509, ll[:longitude].round(6)
    grid = Mgrs.new('14TQM3092028750')
    assert_equal 41.777008, grid.latitude.round(6)
    assert_equal -96.221509, grid.longitude.round(6)
  end
  
  def test_parsing
    grid = Mgrs.new('20UPG4825111932')
    assert_equal '20', grid.zone
    assert_equal 'U', grid.band
    assert_equal 'P', grid.e100k
    assert_equal 'G', grid.n100k
    assert_equal '48251', grid.easting
    assert_equal '11932', grid.northing
  end
  
  def test_centering
    grid = Mgrs.new('20UPB0000000000')
    grid.center!
    assert_equal '20UPB5000050000', grid.to_s
    grid.center!
    assert_equal '20UPB5500055000', grid.to_s
    grid.center!
    assert_equal '20UPB5550055500', grid.to_s
    grid.center!
    assert_equal '20UPB5555055550', grid.to_s
    grid.center!
    assert_equal '20UPB5555555555', grid.to_s
    grid.center!
    assert_equal '20UPB5555555555', grid.to_s
    grid = Mgrs.new('20UPB1000000000')
    grid.center!
    assert_equal '20UPB1500005000', grid.to_s
    grid = Mgrs.new('20UPB0000010000')
    grid.center!
    assert_equal '20UPB0500015000', grid.to_s
  end
  
  def test_class_valid
    grid = Mgrs.new('20UPG4825111932')
    assert_equal true, grid.valid?
    grid = Mgrs.new('20UPX4825111932')
    assert_equal false, grid.valid?
  end
  
  def test_short_name
    grid = Mgrs.new('20UPG4825111932')
    assert_equal true, grid.valid?
    assert_equal '20UPG4825111932', grid.short_name
    grid = Mgrs.new('20UPG4825011930')
    assert_equal '20UPG48251193', grid.short_name
    grid = Mgrs.new('20UPG4820011900')
    assert_equal '20UPG482119', grid.short_name
    grid = Mgrs.new('20UPG4000011900')
    assert_equal '20UPG400119', grid.short_name
    grid = Mgrs.new('20UPG4000000000')
    assert_equal '20UPG40', grid.short_name
    grid = Mgrs.new('20UPG0000000000')
    assert_equal '20UPG', grid.short_name
  end
  
  def test_distance
    grid = Mgrs.new('20UPG4825111932')
    grid2 = Mgrs.new('14TQM3092028750')
    dist = grid.distance_to grid2
    assert_equal "2970.312 km", dist
  end
  
  def test_lat_long_conversion_2
    m =  Mgrs.from_latlon(48.858519, 2.294501)
    assert_equal "31UDQ4824011968", m.to_s
  end
  
end
