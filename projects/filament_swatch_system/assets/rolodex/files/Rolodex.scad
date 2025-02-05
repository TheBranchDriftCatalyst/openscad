// Resolution
$fn = 90 + 0;

// Which parts should be displayed
Parts = "All"; //["All", "Wheel", "Axle", "Knob", "Stand Ends", "Stand Bars"]

// Select "Display Duplicates" to see all stand parts.
Display_Duplicates = 1; // [1:Display Duplicates, 0:Hide Duplicates]

// Width of largest swatch or card stored on this stand.
Swatch_Width = 110.01;

// Height of largest swatch stored on this stand.
Swatch_Height = 60.01;

// Include a preview of swatches on this stand.
Swatch_Preview = true;

// Space between axle and tightly fitting parts.
Axle_Tolerance = 0.125;

// Add guide peg holes to axle.
Axle_Guide_Peg_Holes = true;

// Thickness of all stand parts.
Stand_Thickness = 4;

// Space between stand parts.
Stand_Tolerance = 0.125;

// Text to display on the stand.
Stand_Text = "PLA";

// Font to display stand text in.
Stand_Text_Font = "Liberation Sans:style=Bold";

// Diameter of wheel that holds swatches. Use a smaller diameter for few swatches and increase as needed.
Wheel_Diameter = 56; //[30.0:0.01:60.0]

axle_length = Swatch_Width + Stand_Thickness * 2 + 24;
axle_radius = 5 + 0;
wheel_radius = Wheel_Diameter / 2;
wheel_track_radius = wheel_radius - 8;
knob_radius = 30 + 0;
stand_height = Swatch_Height + wheel_track_radius + knob_radius / 2;

rotate([90, 0, 90]) {

  // Axle
  if (Parts == "All" || Parts == "Axle") {
    difference () {
      cylinder(axle_length, axle_radius, axle_radius, true, $fn = 6);
      if (Axle_Guide_Peg_Holes) {
        rotate ([90, 0, 0]) {
          translate ([0, axle_length / 2 - 12 - Stand_Thickness, 0]) {
            cylinder(axle_radius * 2, 0.9, 0.9, true);
          }
        }
        rotate ([90, 0, 0]) {
          translate ([0, -axle_length / 2 + 12 + Stand_Thickness, 0]) {
            cylinder(axle_radius * 2, 0.9, 0.9, true);
          }
        }
      }
    }
  }

  // Wheel
  if (Parts == "All" || Parts == "Wheel") {
    for(i=[0:1:Display_Duplicates]) {
      rotate([0, 180 * i, 0]) {
        translate ([0, 0, 10]) {
          difference () {
            union () {
              difference () {
                union () {
                  // Wheel outer edge
                  cylinder(4, wheel_radius, wheel_radius, true);
                  // Wheel outer edge - right outer chamfer
                  translate ([0, 0, 2.125]) {
                    cylinder(0.25, wheel_radius, wheel_radius - 0.25, true);
                  }
                  // Wheel outer edge - Wheel left outer chamfer
                  translate ([0, 0, -2.125]) {
                    cylinder(0.25, wheel_radius - 0.25, wheel_radius, true);
                  }
                }
                union () {
                  // Wheel inner edge
                  cylinder(6, wheel_radius - 3, wheel_radius - 3, true);
                  // Wheel inner edge - right inner chamfer
                  translate ([0, 0, 2.25]) {
                    cylinder(0.5, wheel_radius - 3, wheel_radius - 2.5, true);
                  }
                  // Wheel inner edge - left inner chamfer
                  translate ([0, 0, -2.25]) {
                    cylinder(0.5, wheel_radius - 2.5, wheel_radius - 3, true);
                  }
                }
              }
              // Inner disk
              cylinder(2, wheel_radius, wheel_radius, true);
              // Inner ring left
              translate ([0, 0, -1.5]) {
                cylinder(1.5, wheel_radius - 8.5, wheel_radius - 7.5, true);
              }
              // Inner ring right
              translate ([0, 0, 1.5]) {
                cylinder(1.5, wheel_radius - 7.5, wheel_radius - 8.5, true);
              }
              // Add Paddles
              for(j=[0:1:2]) {
                rotate([0, 0, 60 * j]) {
                  cube([Wheel_Diameter - 2, 1, 4.5], true);
                }
              }
            }
            // Center Hole
            cylinder(6, axle_radius + Axle_Tolerance, axle_radius + Axle_Tolerance, true, $fn = 6);
          }
        }
      }
    }
  }

  // Knob
  if (Parts == "All" || Parts == "Knob") {
    for(i=[0:1:Display_Duplicates]) {
      rotate([0, 180 * i, 0]) {
        difference () {
          union () {
            // Knob
            translate ([0, 0, axle_length / 2 + 0.25]) {
              cylinder(8, knob_radius, knob_radius, true);
            }
            // Knob chamfer
            translate ([0, 0, axle_length / 2 - 6.75]) {
              cylinder(6, knob_radius - 3, knob_radius, true);
            }
            // Knob chamfer
            translate ([0, 0, axle_length / 2 + 7.25]) {
              cylinder(6, knob_radius, knob_radius - 3, true);
            }
          }

          // Center Hole
          cylinder(axle_length + 0.25, axle_radius + Axle_Tolerance, axle_radius + Axle_Tolerance, true, $fn = 6);

          // Grip
          for(i=[0:1:24]) {
            rotate([0, 0, 15 * i]) {
              translate ([knob_radius + 1.5, 0, 0]) {
                cylinder(axle_length * 2, 3, 3, true);
              }
            }
          }
        }
      }
    }
  }

  // Stand Ends
  if (Parts == "All" || Parts == "Stand Ends") {
    for(i=[0:1:Display_Duplicates]) {
      rotate([0, 180 * i, 0]) {
        translate ([0, 0, axle_length / 2 - 14.5]) {
          difference () {
            union () {
              cylinder(Stand_Thickness, knob_radius / 2, knob_radius / 2);
              rotate([0, 0, 150]) {
                cube([knob_radius / 2, stand_height,  Stand_Thickness]);
                translate ([0, stand_height, 0]) {
                  cylinder(Stand_Thickness, knob_radius / 2, knob_radius / 2);
                  rotate([0, 0, 120]) {
                    cube([knob_radius / 2, stand_height,  Stand_Thickness]);
                  }
                }
              }
              mirror([1,0,0]) {
                rotate([0, 0, 150]) {
                  cube([knob_radius / 2, stand_height,  Stand_Thickness]);
                  translate ([0, stand_height, 0]) {
                    cylinder(Stand_Thickness, knob_radius / 2, knob_radius / 2);
                  }
                }
              }
            }
            cylinder(axle_length, axle_radius + Axle_Tolerance, axle_radius + Axle_Tolerance, true, $fn = 12);
            rotate([0, 0, 150]) {
              translate ([0, stand_height, 0]) {
                rotate([0, 0, 60]) {
                  translate ([-knob_radius / 2, 0, 0]) {
                  cube([knob_radius, Stand_Thickness + Stand_Tolerance, Stand_Thickness * 3], true);
                  }
                }
              }
            }
            rotate([0, 0, -150]) {
              translate ([0, stand_height, 0]) {
                rotate([0, 0, 120]) {
                  translate ([-knob_radius / 2, 0, 0]) {
                  cube([knob_radius, Stand_Thickness + Stand_Tolerance, Stand_Thickness * 3], true);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Stand Bars
  if (Parts == "All" || Parts == "Stand Bars") {
    for(i=[0:1:1]) {
      mirror ([i, 0, 0]) {
        translate([stand_height, -stand_height, 0]) {
          union () {
            if (i == 1) {
              translate([0, Stand_Thickness, 0]) {
                rotate([90, -90, 0]) {
                  linear_extrude(height = Stand_Thickness) {
                    text(size = knob_radius / 3, text = Stand_Text, font = Stand_Text_Font, valign= "center", halign= "center");
                  }
                }
              }
            }
            difference() {
                cube([knob_radius / 2, Stand_Thickness, axle_length - 10], true);

                translate([knob_radius / 2, 0, axle_length / 2 - 8.5 - Stand_Thickness]) {
                  cube([knob_radius, Stand_Thickness + 1, Stand_Thickness + Stand_Tolerance], true);
                }
                translate([knob_radius / 2, 0, -axle_length / 2 + 8.5 + Stand_Thickness]) {
                  cube([knob_radius, Stand_Thickness + 1, Stand_Thickness + Stand_Tolerance], true);
                }
            }

          }
        }
      }
    }
  }
}

// Swatch preview
if (Parts == "All" && Swatch_Preview) {
  for(i=[0:1:23]) {
    rotate([15 * i, 0, 0]) {
      translate ([0, 0, Swatch_Height/2 + wheel_track_radius]) {
        color ([0.5, 0.5, 0, 0.5]) {
          cube([Swatch_Width, 1.2, Swatch_Height], true);
        }
      }
    }
  }
}
