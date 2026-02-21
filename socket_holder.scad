// Socket Holder Generator
// Generates thin-walled cylindrical tubes for each socket,
// with overlapping walls so adjacent inner bores are separated
// by exactly one wall thickness.
// Edit the `sockets` array below with your socket diameters (in mm).

// --- Configuration ---

// Socket outer diameters in mm
sockets = [11.85, 11.85, 11.85, 11.85, 11.85, 12.8, 13.8, 15.8, 17.7, 19.75];

wall = 2;           // Wall thickness (mm)
depth = 15;         // Height of each tube (mm)
base_h = 2;         // Solid floor thickness inside each tube (mm)
clearance = 0.05;   // Extra diameter added for fit (mm)

$fn = 256;

// --- Derived values ---

num = len(sockets);

// Inner diameter per socket (with clearance)
function inner_d(i) = sockets[i] + clearance;

// Inner radius
function inner_r(i) = inner_d(i) / 2;

// Outer diameter per socket (for rendering the tube)
function outer_d(i) = inner_d(i) + wall * 2;

// X center of tube i
// Distance between centers = inner_r(i-1) + wall + inner_r(i)
// This puts exactly `wall` mm between the two inner bores.
function tube_x(i) =
    i == 0
    ? outer_d(0) / 2
    : tube_x(i - 1) + inner_r(i - 1) + wall + inner_r(i);

// Total width
total_width = tube_x(num - 1) + outer_d(num - 1) / 2;

// --- Modules ---

// A single thin-walled tube with a solid bottom
module socket_tube(i) {
    od = outer_d(i);
    id = inner_d(i);

    // Hole in the base leaves a 2mm ring for the socket to sit on
    base_hole_d = id - wall * 2;

    difference() {
        cylinder(d = od, h = depth);
        translate([0, 0, base_h])
            cylinder(d = id, h = depth - base_h + 1);
        // Punch through the base floor, leaving a ring
        if (base_hole_d > 0)
            translate([0, 0, -0.5])
                cylinder(d = base_hole_d, h = base_h + 1);
    }
}

// --- Render ---

for (i = [0:num-1]) {
    translate([tube_x(i), 0, 0])
        socket_tube(i);
}
