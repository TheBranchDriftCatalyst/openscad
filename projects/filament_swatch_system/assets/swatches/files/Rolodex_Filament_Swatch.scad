$fn = 30 + 0;
in_to_mm = 25.4 + 0;


// What parts should be included?
Parts = "All"; //["All", "Card", "Spacer"]

// What units are the card & spacer measurements below in?
Units = 25.4; // [1:mm, 25.4:in]

// How wide is the card?
Card_Width = 4.25;
converted_card_width = Card_Width * Units;

// How tall is the card?
Card_Height = 2.25;
converted_card_height = Card_Height * Units;

// How much margin separates the edge of the card from text?
Card_Margin = 0.25;
converted_card_margin = Card_Margin * Units;

// How wide is the spacer?
Spacer_Width = 2.25;
converted_spacer_width = Spacer_Width * Units;

// How tall is the spacer?
Spacer_Height = 0.75;
converted_spacer_height = Spacer_Height * Units;

// How rounded should the card/spacer corners be?
Card_Corner_Radius = 0.125;
converted_card_corner_radius = Card_Corner_Radius * Units;

// How far from the center should the track holes be?
Card_Hole_Offset = 0.75;
converted_card_hole_offset = Card_Hole_Offset * Units;

// Include holes to attach to a Rollodex style track.
Card_Holes = true;

// Indicate this is a favorite with a star icon.
Star = false;

// Include a layer heights preview.
Layer_Heights_Preview = true;

// Include a bridging test.
Bridging_Test = false;

// How much space (mm) should be between each line of text?
Line_Margin = 2.5; // [0:1:4]

// How far should text be raised above the card surface?
Text_Offset = 0.6;

// Select a text position for line 1.
Line_1_Position = "Left"; //["Left", "Center"]
// Select a text position for line 2.
Line_2_Position = "Left"; //["Left", "Center"]
// Select a text position for line 3.
Line_3_Position = "Left"; //["Left", "Center"]
// Select a text position for line 4.
Line_4_Position = "Left"; //["Left", "Center"]

// Select a font for line 1.
Line_1_Font = "Liberation Sans:style=Bold";
// Select a font for line 2.
Line_2_Font = "Liberation Sans:style=Normal";
// Select a font for line 3.
Line_3_Font = "Liberation Sans:style=Italic";
// Select a font for line 4.
Line_4_Font = "Liberation Sans:style=Italic";
// Select a font for spacer.
Spacer_Font = "Liberation Sans:style=Bold";

// Select a font size (mm) for line 1.
Line_1_Font_Size = 8; // [4:1:24]
// Select a font size (mm) for line 2.
Line_2_Font_Size = 8; // [4:1:24]
// Select a font size (mm) for line 3.
Line_3_Font_Size = 6; // [4:1:24]
// Select a font size (mm) for line 4.
Line_4_Font_Size = 6; // [4:1:24]
// Select a font size (mm) for spacer.
Spacer_Font_Size = 8; // [4:1:24]

Line_1_Text = "Brand Name";
Line_2_Text = "Color";
Line_3_Text = "200-215 C";
Line_4_Text = "PLA";
Spacer_Text = "";

// How thick is the card (mm)?
Card_Thickness = 1.2; //[1.2:0.2:4.0]

// Thickness for the bottom of the card.
lower_card_thickness = 0.6;

// Layer heights constants
layer_heights_step_height = converted_card_margin / 2;
layer_heights_step_width = converted_card_width / 7;

// Hole constants
hole_width = 1/4 * in_to_mm;
hole_height = 5/16 * in_to_mm;
hole_y = 5/16 * in_to_mm;
hole_track_width = 1/8 * in_to_mm;

// Add more thickness to the spacer?
Spacer_Bump_Height = 0; // [0:0.5:5]

// Use this setting to render text separately from card.
// Can be used for multicolor printing.
Render_Section = "Card and Text"; //["Card and Text", "Text Only", "Card Only"]


if (Parts == "All" || Parts == "Card") {

  difference() {

    union() {

      difference() {

        // Card body
        translate([-converted_card_width/2, 0, 0]){
          cube([converted_card_width, Card_Thickness, converted_card_height], false);
        }

        if (Card_Holes) {

          // Cut out left hole
          translate([-converted_card_hole_offset, 0, hole_y]){
            cube([hole_width, Card_Thickness * 3, hole_height], true);
          }
          translate([-converted_card_hole_offset, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 2], true);
          }

          // Cut out right hole
          translate([converted_card_hole_offset, 0, hole_y]){
            cube([hole_width, Card_Thickness * 3, hole_height], true);
          }
          translate([converted_card_hole_offset, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 2], true);
          }

          // Cut out center hole
          translate([0, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 3], true);
          }

        }

        // Cut out space for top left rounded corners
        translate ([-converted_card_width / 2, 0, converted_card_height]) {
          cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
        }
        // Cut out space for top right rounded corners
        translate ([converted_card_width / 2, 0, converted_card_height]) {
          cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
        }
        // Cut out space for bottom left rounded corners
        translate ([-converted_card_width / 2, 0, 0]) {
          cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
        }
        // Cut out space for bottom right rounded corners
        translate ([converted_card_width / 2, 0, 0]) {
          cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
        }

      }

      // Line 1
      if (Line_1_Position == "Left") {
        translate ([-converted_card_width / 2 + converted_card_margin, 0, converted_card_height - converted_card_margin]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_1_Font_Size, text = Line_1_Text, font = Line_1_Font, valign= "top");
            }
          }
        }
      }
      else if (Line_1_Position == "Center") {
        translate ([0, 0, converted_card_height - converted_card_margin]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_1_Font_Size, text = Line_1_Text, font = Line_1_Font, valign= "top", halign="center");
            }
          }
        }
      }

      // Line 2
      if (Line_2_Position == "Left") {
        translate ([-converted_card_width / 2 + converted_card_margin, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_Margin]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_2_Font_Size, text = Line_2_Text, font = Line_2_Font, valign= "top");
            }
          }
        }
      }
      else if (Line_2_Position == "Center") {
        translate ([0, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_Margin]) {
            rotate([90, 0, 0]) {
              linear_extrude(height = Text_Offset, $fn = 100) {
                text(size = Line_2_Font_Size, text = Line_2_Text, font = Line_2_Font, valign= "top", halign="center");
              }
            }
        }
      }

      // Line 3
      if (Line_3_Position == "Left") {
        translate ([-converted_card_width / 2 + converted_card_margin, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_2_Font_Size - Line_Margin * 2]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_3_Font_Size, text = Line_3_Text, font = Line_3_Font, valign= "top");
            }
          }
        }
      }
      else if (Line_3_Position == "Center") {
        translate ([0, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_2_Font_Size - Line_Margin * 2]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_3_Font_Size, text = Line_3_Text, font = Line_3_Font, valign= "top", halign="center");
            }
          }
        }
      }

      // Line 4
      if (Line_4_Position == "Left") {
        translate ([-converted_card_width / 2 + converted_card_margin, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_2_Font_Size - Line_3_Font_Size - Line_Margin * 3]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_4_Font_Size, text = Line_4_Text, font = Line_4_Font, valign= "top");
            }
          }
        }
      }
      else if (Line_4_Position == "Center") {
        translate ([0, 0, converted_card_height - converted_card_margin - Line_1_Font_Size - Line_2_Font_Size - Line_3_Font_Size - Line_Margin * 3]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Line_4_Font_Size, text = Line_4_Text, font = Line_4_Font, valign= "top", halign="center");
            }
          }
        }
      }


      // Add top left rounded corner
      translate ([-converted_card_width / 2 + converted_card_corner_radius, Card_Thickness/2, converted_card_height - converted_card_corner_radius]) {
        rotate([90, 0, 0]) {
          cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
        }
      }
      // Add top right rounded corner
      translate ([converted_card_width / 2 - converted_card_corner_radius, Card_Thickness/2, converted_card_height - converted_card_corner_radius]) {
        rotate([90, 0, 0]) {
          cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
        }
      }
      // Add bottom left rounded corner
      translate ([-converted_card_width / 2 + converted_card_corner_radius, Card_Thickness/2, converted_card_corner_radius]) {
        rotate([90, 0, 0]) {
          cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
        }
      }
      // Add bottom right rounded corner
      translate ([converted_card_width / 2 - converted_card_corner_radius, Card_Thickness/2, converted_card_corner_radius]) {
        rotate([90, 0, 0]) {
          cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
        }
      }

    }

    // Star
    if (Star) {
      translate([converted_card_width / 2 - 7.5, Card_Thickness + 1, converted_card_height - 7.5]) {
        rotate([90,180,0]) {
            linear_extrude(Card_Thickness + 2) {
              polygon([[0,-4],[1,-1.25],[3.75,-1.25],[1.5,0.425],[2.375,3],[0,1.5],[-2.375,3],[-1.5,0.425],[-3.75,-1.25],[-1,-1.25]]);
            }
        }
      }
    }

    // Layer heights preview
    if (Layer_Heights_Preview) {
      translate([0, 0, converted_card_height]) {
        translate([-layer_heights_step_width * 2, (Card_Thickness - 1.2)/2 - 0.4, 0]) {
          cube([layer_heights_step_width, Card_Thickness, layer_heights_step_height * 2], true);
        }
        translate([-layer_heights_step_width, (Card_Thickness - 1.2)/2 - 0.2, 0]) {
          cube([layer_heights_step_width, Card_Thickness, layer_heights_step_height * 2], true);
        }
        translate([0, (Card_Thickness - 1.2)/2, 0]) {
          cube([layer_heights_step_width, Card_Thickness, layer_heights_step_height * 2], true);
        }
        translate([layer_heights_step_width, (Card_Thickness - 1.2)/2 + 0.2, 0]) {
          cube([layer_heights_step_width, Card_Thickness, layer_heights_step_height * 2], true);
        }
        translate([layer_heights_step_width * 2, (Card_Thickness - 1.2)/2 + 0.4, 0]) {
          cube([layer_heights_step_width, Card_Thickness, layer_heights_step_height * 2], true);
        }
      }
    }

    // Bridging Test
    if (Bridging_Test) {
      translate([converted_card_width/2, Card_Thickness, converted_card_height/2]) {
        cube([converted_card_margin * 2, Card_Thickness, converted_card_height/2], true);
      }
    }
    
    if (Card_Holes) {
      // Thin bottom edge
      translate([0, Card_Thickness/2 - lower_card_thickness, 0]) {
        cube([converted_card_width, Card_Thickness, hole_y * 3], true);
      }

    }

    if (Render_Section == "Card Only") {
      translate([-converted_card_width/2 - 1, -Card_Thickness * 4, -1]) {
        cube([converted_card_width + 2, Card_Thickness * 4, converted_card_height + 2]);
      }
    }

    else if (Render_Section == "Text Only") {
      translate([-converted_card_width/2 - 1, 0, -1]) {
        cube([converted_card_width + 2, Card_Thickness * 4, converted_card_height + 2]);
      }
    }

  }

}

spacer_bump_thickness = 2 + 0;
spacer_left_margin = 4;
spacer_right_margin = 4;
spacer_bottom_margin = hole_y + hole_height/2 + spacer_bump_thickness + 4;

if (Parts == "All" || Parts == "Spacer") {

  translate([0, 0, converted_card_height + 10]) {

    difference() {
      
      union() {
        
        difference() {

          union() {

            // Spacer body
            translate([-converted_spacer_width/2, 0, 0]){
              cube([converted_spacer_width, Card_Thickness, converted_spacer_height], false);
            }

            // Add spacer bump
            if (Spacer_Bump_Height > 0) {
              translate([-converted_spacer_width/2, -Spacer_Bump_Height, hole_y + hole_height / 2]){
                cube([converted_spacer_width, Spacer_Bump_Height, spacer_bump_thickness]);
              }
            }

          }

          // Cut out left hole
          translate([-converted_card_hole_offset, 0, hole_y]){
            cube([hole_width, Card_Thickness * 3, hole_height], true);
          }
          translate([-converted_card_hole_offset, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 2], true);
          }

          // Cut out right hole
          translate([converted_card_hole_offset, 0, hole_y]){
            cube([hole_width, Card_Thickness * 3, hole_height], true);
          }
          translate([converted_card_hole_offset, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 2], true);
          }

          // Cut out center hole
          translate([0, 0, 0]){
            cube([hole_track_width, Card_Thickness * 3, hole_y * 3], true);
          }

          // Cut out space for top left rounded corners
          translate ([-converted_spacer_width / 2, 0, converted_spacer_height]) {
            cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
          }
          // Cut out space for top right rounded corners
          translate ([converted_spacer_width / 2, 0, converted_spacer_height]) {
            cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
          }
          // Cut out space for bottom left rounded corners
          translate ([-converted_spacer_width / 2, 0, 0]) {
            cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
          }
          // Cut out space for bottom right rounded corners
          translate ([converted_spacer_width / 2, 0, 0]) {
            cube([converted_card_corner_radius * 2, Card_Thickness * 3, converted_card_corner_radius * 2], true);
          }

        }

        // Add top left rounded corner
        translate ([-converted_spacer_width / 2 + converted_card_corner_radius, Card_Thickness/2, converted_spacer_height - converted_card_corner_radius]) {
          rotate([90, 0, 0]) {
            cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
          }
        }
        // Add top right rounded corner
        translate ([converted_spacer_width / 2 - converted_card_corner_radius, Card_Thickness/2, converted_spacer_height - converted_card_corner_radius]) {
          rotate([90, 0, 0]) {
            cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
          }
        }
        // Add bottom left rounded corner
        translate ([-converted_spacer_width / 2 + converted_card_corner_radius, Card_Thickness/2, converted_card_corner_radius]) {
          rotate([90, 0, 0]) {
            cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
          }
        }
        // Add bottom right rounded corner
        translate ([converted_spacer_width / 2 - converted_card_corner_radius, Card_Thickness/2, converted_card_corner_radius]) {
          rotate([90, 0, 0]) {
            cylinder(Card_Thickness, converted_card_corner_radius, converted_card_corner_radius, true);
          }
        }

        // Spacer text
        translate ([0, 0, converted_spacer_height - Spacer_Font_Size / 2]) {
          rotate([90, 0, 0]) {
            linear_extrude(height = Text_Offset, $fn = 100) {
              text(size = Spacer_Font_Size, text = Spacer_Text, font = Spacer_Font, halign= "center", valign= "top");
            }
          }
        }

      }

      // Thin bottom edge
      cube([converted_spacer_width, Card_Thickness, hole_y * 3], true);

      // Cut Hole
      translate ([-converted_spacer_width/2 + spacer_left_margin, -1, spacer_bottom_margin]) {
        cube([converted_spacer_width - spacer_left_margin - spacer_right_margin, 4, converted_spacer_height - spacer_bottom_margin - Spacer_Font_Size * 2 ]);
      }



      if (Render_Section == "Card Only") {
        translate([-converted_spacer_width/2 - 1, -Card_Thickness * 4, -1]) {
          cube([converted_spacer_width + 2, Card_Thickness * 4, converted_spacer_height + 2]);
        }
      }

      else if (Render_Section == "Text Only") {
        translate([-converted_spacer_width/2 - 1, 0, -1]) {
          cube([converted_spacer_width + 2, Card_Thickness * 4, converted_spacer_height + 2]);
        }
      }

    }

  }

}
