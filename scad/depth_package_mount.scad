include <../library/roundedcube.scad>

width = 174;
height = 115;
thickness = 3;

function signum(x) = x/abs(x);

module cutoff_corners()
{
    corner_side_length = 20;
    
    for( x = [0, width] )
    {
        for( y = [0, height] )
        {
            translate([x, y -sqrt(2*corner_side_length*corner_side_length)/2, 0])
            rotate([0, 0, 45])
            cube([corner_side_length, corner_side_length, thickness]);
        }
    }
}

module base()
{
    difference()
    {
        cube([width, height, thickness]);
        cutoff_corners();
    }
}

//bounding_circle_diameter = 37.5;
bounding_circle_diameter = 40;
bounding_circle_radius = bounding_circle_diameter/2;
//bounding_circle_offset = 5;
bounding_circle_offset = 3;

module bounding_cylinders()
{

    linear_extrude(height=thickness)
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

allowance = 20;
hole_width = width   - allowance;
hole_height = height - allowance;

difference()
{
    union()
    {
        translate([-width/2, -height/2, 0])
        base();

        bounding_cylinders();
    }
    union()
    {
        translate([-hole_width/2, -hole_height/2, 0])
        cube([hole_width, hole_height, thickness]);
    }
}