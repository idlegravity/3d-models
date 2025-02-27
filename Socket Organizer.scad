// A simple OpenSCAD script to generate a socket holder for a tool chest drawer.
// © 2024 idlegravity
// This work is licensed under a Creative Commons (4.0 International License):
// Attribution-NonCommercial (https://creativecommons.org/licenses/by-nc/4.0/)

// --- User defined variables ---
// Rows of sockets. A socket is defined by its [diameter, depth, label]
sockets = [
    [ [ 26, 20, "17" ], [ 28, 20, "18" ], [ 28, 20, "19" ], [ 30, 20, "21" ], [ 32, 20, "22" ], [ 38, 20, "27" ] ],
    [ [ 24, 20, "10" ], [ 24, 20, "11" ], [ 24, 20, "12" ], [ 24, 20, "13" ], [ 24, 20, "14" ], [ 24, 20, "15" ], [ 24, 20, "16" ] ],
    [
        [ 11.7, 12, "4mm" ],
        [ 11.7, 12, "5mm" ],
        [ 11.7, 12, "6mm" ],
        [ 11.7, 12, "7mm" ],
        [ 11.7, 12, "8mm" ],
        [ 12.9, 12, "9mm" ],
        [ 14.4, 12, "10mm" ],   
        [ 15.8, 12, "11mm" ],
        [ 16.7, 12, "12mm" ],
        [ 17.5, 12, "13mm" ],
        [ 19.5, 12, "14mm" ] ],
];

/* [General Options] */
// Space between sockets and the edge of the tray
margin = 2;
// Minimum space between each socket
min_padding = 2;                // Padding may be increased on some rows to keep spacing even.
min_bottom_thickness = 2;       // Space between the deepest socket and the bottom of the tray.
// Radius for tray corners
Corner_radius = 4; //[1:0.5:30]
Box_style = 1; // [1:plain, 2:rounded, 3:gridfinity]
Opacity = 1.0; // [0.0:0.05:1.0]
Box_color = "gray"; // [white, red, purple, green, blue, light_blue, black]
Text_color = "white"; // [black, gray, red, green, blue, lightblue]

/* [Socket Labels] */
include_labels = true;          // Should text labels be included?  If set to false they will be omitted.
label_text_size = 3;            // Font size for the socket labels.
label_depth = 1;                // Depth of the raised labels. Positive is raised, negative is embossed.
aligned_labels = false;         // If true, labels will be vertically aligned on each row. If false, labels will be offset from the sockets.

/* [Main Tray Label] */
Include_tray_label = false;     // [false:No label, true:Add label]
Tray_label_position = 1;        // [1:Top-Center, 2:Top-Left, 3:Top-Right, 4:Bottom-Center, 5:Bottom-Left, 6:Bottom-Right]
// Extra text label to be added to the tray
tray_text = "Metric ⅜\" Drive"; // "Metric ⅜\" Drive", "Metric ¼\" Drive", "Metric ½\" Drive"
// Font size for the tray text.
tray_text_size = 5;
// Minimum tray width (mm), zero for auto-width
min_tray_width = 0;             // If the sockets will fit in this width, it will be used. If not, the tray will be as wide as necessary.
                                // It might be fun to do the same thing with the height and depth but I haven't implemented that yet.

// Render smoothness, 100 for nice, smooth circles.
$fn=100; // [10:100]



// --- Do not edit below this line ---

// --- Vars to Hide From Customizer -- //
function clearance() = .5;      // Additional clearance around each socket.


// Predefined OpenSCAD colors as RGB values
predefined_colors = [
    ["red",        [0.8, 0, 0]],
    ["purple",     [0.5, 0.0, 0.5]],
    ["green",      [0, 1, 0]],
    ["blue",       [0, 0, 1]],
    ["light_blue", [0.68, 0.85, 0.9]],
    ["cyan",       [0, 1, 1]],
    ["magenta",    [1, 0, 1]],
    ["yellow",     [1, 1, 0]],
    ["black",      [0, 0, 0]],
    ["white",      [1, 1, 1]],
    ["gray",       [0.5, 0.5, 0.5]]
];

socket_hole_color  = lighten_color(Box_color, 0.7);

// Make sure the tray label is setup correctly,
// even if tray_text is not configured.
tray_label = is_undef(tray_text) ? "" : tray_text;

// Separate the diameter, depth, and label values into their own arrays for convenience.
diameters = [for (row = sockets) [for (socket = row) socket[0] + clearance()]];
depths = [for (row = sockets) [for (socket = row) socket[1]]];
labels = [for (row = sockets) [for (socket = row) socket[2]]];
// echo("diameters", diameters);
// echo("depths", depths);
// echo("labels", labels);

// Calculate the maximum diameter of each row.
max_row_diameters = [for (row = diameters) max(row)];
//echo("max_row_diameters", max_row_diameters);

label_size = label_text_size + min_padding;

// Calculate the dimensions of the tray.
tray_x = max(max([for (row = diameters) sumVector(row) + ((len(row) - 1) * min_padding) + (2 * margin)]), min_tray_width);
extra_y = (tray_label != "" && Include_tray_label) ? tray_text_size + 2 * min_padding : 0; // do we need extra Y dimension for the tray label?
tray_y = sumVector(max_row_diameters) + (2 * margin) + (len(sockets) * label_size) + ((len(sockets) - 1) * min_padding) + extra_y;
tray_z = max([for (row = depths) max(row)]) + min_bottom_thickness;
//echo("tray_x", tray_x);
//echo("tray_y", tray_y);
//echo("tray_z", tray_z);

// Calculate the padding for each row.
padding = [for (row = diameters) (tray_x - sumVector(row) - (2 * margin)) / (len(row) - 1)];

socket_x_coords = [
    for (i = [0:len(diameters) - 1]) 
    [for (a = 0, b = (diameters[i][0] / 2) + margin - (tray_x / 2); 
         a < len(diameters[i]); 
         a = a + 1, 
         b = b + ((diameters[i][a - 1] / 2) + (diameters[i][a] == undef ? 0 : (diameters[i][a] / 2))) + padding[i]) 
         b]
];

// Determine what Y-shift needs to happen depending on if the main
// text lable (for the tray) is being included, and if its at the
// "top" or "bottom" of the tray
shift_y = extra_y > 0 ? (trayLabelPositionIsTop() ? 0 : extra_y) : 0;
socket_y_coords = [
    for (i = [0:len(diameters) - 1]) 
    [for (j = [0:len(diameters[i]) - 1]) 
        ((i > 0 ? (cumulativeSum(max_row_diameters, i - 1)[i - 1]) : 0) 
        + (max_row_diameters[i] / 2) 
        + margin 
        + (i * min_padding) 
        + ((i + 1) * label_size))
        - (tray_y / 2) // adjust Y coord to center around Y axis
        + shift_y // shift up if needed (if tray label is on bottom)
    ]
];

// Create the tray and cut out the socket holes.
difference() {
    bin_size = [ tray_x, tray_y, tray_z ];
    color(get_color_by_name(Box_color), Opacity)
    // cube(bin_size);
    tool_tray(bin_size, Corner_radius);
    for (row = [0:len(sockets) - 1]) {
        for (j = [0:len(sockets[row]) - 1]) {
            color(socket_hole_color)
            translate([ socket_x_coords[row][j], socket_y_coords[row][j], tray_z - depths[row][j] ]) cylinder(h = depths[row][j], d = diameters[row][j]);
        }
    }
}

// Add Tray Label
if (Include_tray_label && (extra_y > 0)) {
    label_x = trayLabelPositionIsCenter() ? 0 : (trayLabelPositionIsLeft() ? (-tray_x / 2) + margin : (tray_x / 2) - margin );
    label_alignment = trayLabelAlignment();
    font_name = "Liberation Sans:style=Bold";
    if (trayLabelPositionIsTop()) {
        label_y = (tray_y / 2) - margin;
        color(Text_color)
        translate([label_x, label_y - label_size, tray_z])
        linear_extrude(height = label_depth)
        text(text = tray_text, font = font_name, size = tray_text_size, halign = label_alignment);
    } else {
        label_y = (-tray_y / 2) + margin + label_size + min_padding;
        color(Text_color)
        translate([label_x, label_y - label_size, tray_z])
        linear_extrude(height = label_depth)
        text(text = tray_text, font = font_name, size = tray_text_size, halign = label_alignment);
    }
}

// Add labels
if (include_labels) {
    if (aligned_labels) {
        // Vertically aligned labels.
        for (i = [0:len(sockets) - 1]) {
            for (j = [0:len(sockets[i]) - 1]) {
                color(Text_color)
                translate([socket_x_coords[i][j], margin + (i * min_padding) + (i * label_size) + (i > 0 ? (cumulativeSum(max_row_diameters, i - 1)[i - 1]) : 0), tray_z])
                linear_extrude(height = label_depth)
                text(text = labels[i][j], font = "Liberation Sans:style=Bold", size = label_text_size, halign = "center");
            }
        }
    } else {
        // Labels offset from the sockets.
        for (i = [0:len(sockets) - 1]) {
            for (j = [0:len(sockets[i]) - 1]) {
                color(Text_color)
                translate([socket_x_coords[i][j], socket_y_coords[i][j] - (diameters[i][j] / 2) - label_size, tray_z])
                linear_extrude(height = label_depth)
                text(text = labels[i][j], font = "Liberation Sans:style=Bold", size = label_text_size, halign = "center");
            }
        }
    }
}

// --- Conveneience functions ---
// Sum all elements of a vector.
function sumVector(v) = [for (p = v) 1] * v;

// Cumulative sum of a vector up given index.
function cumulativeSum(v, index) = [for (a = v[0] - v[0], i = 0; i <= index; a = a + v[i], i = i + 1) a + v[i]];

// Helpers for the tray label
function trayLabelPositionIsTop() = (Tray_label_position <= 3);
function trayLabelPositionIsCenter() = (Tray_label_position == 1 || Tray_label_position == 4);
function trayLabelPositionIsLeft() = (Tray_label_position == 2 || Tray_label_position == 5);
function trayLabelPositionIsRight() = (Tray_label_position == 3 || Tray_label_position == 6);
function trayLabelAlignment() = trayLabelPositionIsCenter() ? "center" : (trayLabelPositionIsLeft() ? "left" : "right");

// Gets the four "post" cylinders that define the corners of the box
module posts(x,y,z,h,r) {
    translate([x,y,z]) {
        cylinder(r = r, h = h);
    }
    translate([-x,y,z]) {
        cylinder(r = r, h = h);
    }
    translate([-x,-y,z]) {
        cylinder(r = r, h = h);
    }
    translate([x,-y,z]) {
        cylinder(r = r, h = h);
    }
}

// Generate the a tool tray box
//   * size is the [width, length, height]
//   * radius is the corner radious for the vertial edges
module tool_tray(size, radius) {
    width = size[0];
    length = size[1];
    height = size[2];
    hull() {
        posts(
            x=(width/2 - radius),
            y=(length/2 - radius),
            z=0,
            h=height,
            r=radius
        );
    }
}

// Function to get an RGB color by name from the color list.
//   * Return undef if the color isn't found.
function get_color_by_name(color_name) =
    let(index = [for (i = [0:len(predefined_colors)-1]) if (predefined_colors[i][0] == color_name) i])
    (len(index) > 0 ? predefined_colors[index[0]][1] : undef);

// Function to lighten a predefined color name
//   * Default is to return "gray" color if color_name isn't defined
//   * Alpha value is preserved alpha if exists
function lighten_color(color_name, factor) =
    let(color = get_color_by_name(color_name))
    color == undef ? [0.5, 0.5, 0.5] :
    [
        color[0] * (1 - factor) + 1 * factor,
        color[1] * (1 - factor) + 1 * factor,
        color[2] * (1 - factor) + 1 * factor,
        (len(color) > 3 ? color[3] : 1)
    ];
 
 // -- end -- 
