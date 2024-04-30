var map;
var projection_wgs;
var projection_smp;
var position;
// == On DOM Ready events =====================================================
$(function() {
  // Define variables for OpenLayers
  var center_lat  = '38.575076';      // Sacramento CA latitude
  var center_lon  = '-121.487761';    // Sacramento CA longitude
  var zoom        = 13;
  var mapnik      = new OpenLayers.Layer.OSM();                // OpenStreetMap Layer
  projection_wgs  = new OpenLayers.Projection("EPSG:4326");    // WGS 1984
  projection_smp  = new OpenLayers.Projection("EPSG:900913");  // Spherical Mercator
  position        = new OpenLayers.LonLat(center_lon, center_lat).transform(projection_wgs, projection_smp);
 
  // Create the map
  map = new OpenLayers.Map('map');    // Argument is the name of the containing div.
  map.addLayer(mapnik);
  map.setCenter(position, zoom);      // Set center of map
 
  // Fix map size on dom ready
  ol.stretch_canvas();
});
 
// == Window.resize events ===================================================
$(window).resize(function() {
  // Fix map size on resize
  ol.stretch_canvas();
});
// == Functions Below =========================================================
var ol = {
  /*
  * ol.stretch_canvas:
  *   Many people experiance an issue where
  *   the container div (map) does not actually stretch to
  *   100%. This function sets the div to the height and width
  *   of the parent div. 100% fix.
  */
  stretch_canvas: function() {
    var oldiv_height = $('#map').parent().css('height');
    var oldiv_width  = $('#map').parent().css('width');
    $('#map').css('height', oldiv_height);
    $('#map').css('width', oldiv_width);
 
  }
}