include <../library/roundedcube.scad>
include <../library/PiHoles.scad>

$fn=160;

width = 174;
height = 115;
thickness = 3;
cutoff_corner_side_length = 20;

function signum(x) = x/abs(x);

module cutoff_corners(cuttoff_corners_width, cuttoff_corners_height, cuttoff_corners_thickness, cuttoff_corners_side_length)
{
    corner_side_length = 20;
    
    for( x = [0, width] )
    {
        for( y = [0, height] )
        {
            translate([x, y -sqrt(2*corner_side_length*corner_side_length)/2, 0])
            rotate([0, 0, 45])
            cube([corner_side_length, corner_side_length, cuttoff_corners_thickness]);
        }
    }
}

module base(base_width, base_height, base_thickness, base_cutoff_corner_side_length)
{
    difference()
    {
        cube([base_width, base_height, base_thickness]);
        cutoff_corners(base_width, base_height, base_thickness, base_cutoff_corner_side_length);
    }
}

module bounding_cylinders(bounding_circle_diameter, bounding_circle_offset, bounding_cylinder_thickness)
{
    bounding_circle_radius = bounding_circle_diameter/2;

    linear_extrude(height=bounding_cylinder_thickness)
    union()
    {
        for( x = [-width/2, width/2] )
        {
            for( y = [-height/2, height/2] )
            {
                x_offset = signum(x) * (abs(x) - bounding_circle_radius +bounding_circle_offset);
                y_offset = signum(y) * (abs(y) - bounding_circle_radius +bounding_circle_offset);
                translate([x_offset, y_offset, 0])
    //            translate([bounding_circle_radius-bounding_circle_offset,  bounding_circle_radius-bounding_circle_offset, 0])
                circle(r=bounding_circle_radius);
            }
        }
    }

}

//allowance = 10;
//hole_width = width   - allowance;
//hole_height = height - allowance;

module contour( contour_width, contour_height, contour_thickness, contour_cutoff_corner_side_length, contour_bounding_circle_diameter, contour_bounding_circle_offset, allowance = 30, hole_width=150, hole_height=90)
{
//    hole_width  = contour_width  - allowance;
//    hole_height = contour_height - allowance;
    
    difference()
    {
        union()
        {
            translate([-contour_width/2, -contour_height/2, 0])
            base(contour_width, contour_height, contour_thickness, contour_cutoff_corner_side_length);

            bounding_cylinders(bounding_circle_diameter=contour_bounding_circle_diameter, bounding_circle_offset=contour_bounding_circle_offset, bounding_cylinder_thickness=contour_thickness);
        }
        union()
        {
            translate([-hole_width/2, -hole_height/2, 0])
            cube([hole_width, hole_height, contour_thickness]);
        }
    }
}

module camera_support(support_width, support_height, support_thickness, camera_base_height)
{
//    camera_base_height = 13; // distance from the bottom of the mount to the bottom of the camera (z-dimension)
    camera_width = 125;
    camera_height = 30;
    
    difference()
    {
        union()
        {
            translate([-support_width/2, -35/2, 0])
            cube([support_width, 35, support_thickness]);
            
            translate([-10/2, -support_height/2, 0])
            cube([10, support_height, support_thickness]);
            
            
        }
        union()
        {
            // relief
            translate([-camera_width/2, -camera_height/2, camera_base_height])
            cube([camera_width, camera_height, support_thickness - camera_base_height]);
            
            translate([-55, -20, camera_base_height])
            cube([30, 20, support_thickness - camera_base_height]);
        }
    }
}

module camera_holes(camera_base_height)
{
    hole_width = 95;
    hole_diameter = 4;
    hole_depth = 4;
    head_diameter = 8;
    head_height = 3;
    
//    translate([-hole_width/2, 0, 0])
    for(x_offset = [-hole_width/2, hole_width/2])
    {
        translate([x_offset, 0, camera_base_height])
        rotate([180, 0, 0])
        union()
        {
            cylinder(d=hole_diameter, h=hole_depth);
            
            translate([0, 0, head_height])
            cylinder(d=head_diameter, h=20);
        }
    }
}

bottom_thickness = 9.5;
top_thickness = 12.5;

total_thickness = top_thickness + bottom_thickness;

camera_base_height = 13;

difference()
{
    // positives
    union()
    {
        // bottom
        contour( 174, 115, 9.5, 20, 40, 3 );

        // top
        translate([0, 0, bottom_thickness])
        contour( 170, 110, top_thickness, 20, 36, 1 );

        // camera_support(174-20, 115-20, 13);
        camera_support(174-20, 115-20, total_thickness, camera_base_height);
    }
    
    // negatives
    union()
    {
        translate([3, -3, 10])
        piHolesWood("3B", 10, true);
        
        camera_holes(camera_base_height);
    }
}

//camera_holes();