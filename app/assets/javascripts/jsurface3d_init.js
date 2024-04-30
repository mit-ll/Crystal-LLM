//= require jsurface3d/three/three
//= require jsurface3d/three/detector
//= require jsurface3d/four/four.buffer
//= require jsurface3d/four/four.buffercount
//= require jsurface3d/four/four.interactivemeshes
//= require jsurface3d/four/four.matlib
//= require jsurface3d/four/four.multimaterial_object
//= require jsurface3d/four/four.scale
//= require jsurface3d/four/four.text3d
//= require jsurface3d/four/four.tube
//= require jsurface3d/jsurface3d/jsurface3d
//= require jsurface3d/jsurface3d/jsurface3d.surfaceworld
//= require jsurface3d/jsurface3d/jsurface3d.axis
//= require jsurface3d/jsurface3d/jsurface3d.hud
//= require jsurface3d/jsurface3d/jsurface3d.plane
//= require jsurface3d/jsurface3d/jsurface3d.slice
//= require jsurface3d/jsurface3d/jsurface3d.smile
//= require jsurface3d/jsurface3d/jsurface3d.surfaceplane
//= require jsurface3d/stats
//= require jsurface3d/fonts/helvetiker/helvetiker_regular.typeface


function jsurface3d_init(surfaceMapData){
    new JSurface3D({
        selector: '.surfaceMap',
        data: surfaceMapData,
        options: {
            /*
            axis_offset: 5,             // X and Z axis distance from the surface
            camera_focus_y_offset: 10,  // Move the focal point of the camera up and down
            floating_height: 20,        // Height the surface floats over the floor
            font_face_3d: 'helvetiker', // 3D text font (glyphs for 3D fonts need to be loaded separately)
            font_size: 34,              // 3D text font size (not in any particular units)
            font_height: 3,             // Extrusion height for 3D text
            font_color: 0x555555,       // Font color for value labels
            font_color_axis_labels: 0x555555,     // Font color for axis labels
            hud: true,                            // Toggle options overlay and volatility display

            interactive_surface_color: 0x555555,  // Highlight for interactive surface elements (in hex)
            interactive_hud_color: '#555',        // Highlight colour for volatility display (in css)
            precision_lbl: 2,                     // Floating point precisions for labels
            precision_hud: 3,                     // Floating point precisions for vol display
            slice_handle_color: 0xbbbbbb,         // Default colour for slice handles
            slice_handle_color_hover: 0x999999,   // Hover colour for slice handles
            slice_bar_color: 0xe7e7e7,            // Default slice bar colour
            slice_bar_color_active: 0xffbd00,     // Active slice bar colour
            smile_distance: 80,                   // Distance the smile planes are from the surface
            snap_distance: 3,                     // Mouse proximity to vertices before an interaction is approved
            surface_x: 100,                       // Width
            surface_z: 100,                       // Depth
            surface_y: 50,                        // The height range of the surface
            texture_size: 512,                    // Texture map size for axis ticks
            tick_length: 10,                      // Axis tick length
            y_segments: 5,                        // Number of segments to thin vol out to for smile planes
            vertex_shading_hue_min: 240,          // vertex shading hue range min value
            vertex_shading_hue_max: 180,          // vertex shading hue range max value
            zoom_default: 200,                    // Bigger numbers are further away
            zoom_sensitivity: 10                  // Mouse wheel sensitivity
            */
        }
    });
}

$(function(){
    $( "#datepicker" ).datepicker();
    if(gon.data.surfacemap !== undefined ){
        jsurface3d_init(gon.data.surfacemap);
    }
});