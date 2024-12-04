{ lib, ... }:
let
  merge = (list: builtins.foldl' (a: b: lib.recursiveUpdate a b) { } list);
  serial = "/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0";
  functions = {
    adxl = {
      "mcu_rpi".serial = "/tmp/klipper_host_mcu";
      adxl345.cs_pin = "rpi:None";
      resonance_tester = {
        accel_chip = "adxl345";
        probe_points = "110, 110, 60";
      };
      "gcode_macro GENERATE_SHAPER_GRAPHS" = {
        description =
          "Generates input shaper resonances graphs for analysis. Uses the AXIS parameter for if you only want to do one axis at a time, (eg. GENERATE_SHAPER_GRAPHS AXIS=X)";
        gcode = "
          {% if params.AXIS is defined %}
              {% if params.AXIS|lower == 'x' %}
                  G28
                  TEST_RESONANCES AXIS=X
                  RESPOND MSG=\"Input shaper graph generated for the X axis\"
              {% elif params.AXIS|lower == 'y' %}
                  G28
                  TEST_RESONANCES AXIS=Y
                  RESPOND MSG=\"Input shaper graph generated for the Y axis\"
              {% else %}
                  {action_raise_error(\"Unknown axis specified. Expected X or Y.\")}
              {% endif %}
          {% else %}
              G28
              TEST_RESONANCES AXIS=X
              TEST_RESONANCES AXIS=Y
          {% endif %}
        ";
      };
    };
    bed_mesh = {
      bed_mesh = {
        speed = 100;
        horizontal_move_z = 5;
        mesh_min = "28, 23";
        mesh_max = "205, 200";
        probe_count = "5, 5";
        fade_start = 1;
        fade_end = 10;
        mesh_pps = "2,2";
        algorithm = "bicubic";
        bicubic_tension = 0.05;
      };
      "gcode_macro BED_MESH".gcode = "
        G28
        M117 Heating bed...
        M190 S{params.BED_TEMP|default(70, true)}
        TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM={params.BED_TEMP|default(70, true)}
        M117 Bed calibrate...
        G28 Z
        M117 Bed mesh...
        BED_MESH_CALIBRATE
        G0 X1 Y115 Z50 F10000
        SAVE_CONFIG
      ";
    };
    display = {
      display = {
        lcd_type = "st7920";
        cs_pin = "PB12";
        sclk_pin = "PB13";
        sid_pin = "PB15";
        encoder_pins = "^PB14, ^PB10";
        click_pin = "^!PB2";
      };
    };
    gantry_calibration = {
      "gcode_macro GANTRY_CALIBRATION".gcode = "
        {% set my_current = 0.12 %}
        {% set oldcurrent = printer.configfile.settings[\"tmc2209 stepper_z\"].run_current %}
        {% set x_max = printer.toolhead.axis_maximum.x %}
        {% set y_max = printer.toolhead.axis_maximum.y %}
        {% set z_max = printer.toolhead.axis_maximum.z %}
        {% set fast_move_z = printer.configfile.settings[\"printer\"].max_z_velocity %}
        {% set fast_move = printer.configfile.settings[\"printer\"].max_velocity %}
        M117 {printer.homed_axes}
        {% if printer.homed_axes != 'xyz' %}
            G28
        {% endif %}
        G90
        G0 X{x_max / 2} Y{y_max / 2} F{fast_move * 30 }
        G0 Z{z_max -1} F{fast_move_z * 60 }
        SET_TMC_CURRENT STEPPER=stepper_z CURRENT={my_current}
        {% if printer.configfile.settings[\"stepper_z1\"] %}
            SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={my_current}
        {% endif %}
        G4 P200
        SET_KINEMATIC_POSITION Z={z_max - 12}
        G1 Z{z_max -2} F{6 * 60}
        G4 P200
        G1 Z{z_max -6} F{6 * 60}
        G4 P200
        SET_TMC_CURRENT STEPPER=stepper_z CURRENT={oldcurrent}
        {% if printer.configfile.settings[\"stepper_z1\"] %}
            SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={oldcurrent}
        {% endif %}
        G1 Z{z_max -30} F{6 * 60}
        G4 P200
        G28 Z
      ";
      "gcode_macro G34".gcode = "GANTRY_CALIBRATION";
      "menu __main __setup __calib __gantry_calibrate" = {
        type = "command";
        enable = ''{not printer.idle_timeout.state == "Printing"}'';
        name = "G34 egantry Level";
        gcode = "G34";
      };
      force_move.enable_force_move = true;
    };
    macros = {
      "gcode_macro LOAD_FILAMENT".gcode = "
        SAVE_GCODE_STATE NAME=load_state
        G91
        # Heat up hotend to provided temp or 220 as default as that should work OK with most filaments.
        {% if params.TEMP is defined or printer.extruder.can_extrude|lower == 'false' %}
          M117 Heating...
          M104 S{params.TEMP|default(220, true)}
          TEMPERATURE_WAIT SENSOR=extruder MINIMUM={params.TEMP|default(220, true)}
        {% endif %}
        M117 Loading filament...
        # Load the filament into the hotend area.
        G0 E65 F400
        # Wait a secod
        G4 P1000
        # Purge
        G0 E40 F100
        # Wait for purge to complete
        M400e
        M117 Filament loaded!
        RESTORE_GCODE_STATE NAME=load_state        
      ";
      "gcode_macro UNLOAD_FILAMENT".gcode = "
          SAVE_GCODE_STATE NAME=unload_state
          G91
          {% if params.TEMP is defined or printer.extruder.can_extrude|lower == 'false' %}
            M117 Heating...
            # Heat up hotend to provided temp or 220 as default as that should work OK with most filaments.
            M104 S{params.TEMP|default(220, true)}
            TEMPERATURE_WAIT SENSOR=extruder MINIMUM={params.TEMP|default(220, true)}
          {% endif %}
          M117 Unloading filament...
          # Extract filament to cold end area
          G0 E-5 F3000
          # Wait for three seconds
          G4 P3000
          # Push back the filament to smash any stringing
          G0 E5 F3000
          # Extract back fast in to the cold zone
          G0 E-15 F3000
          # Continue extraction slowly, allow the filament time to cool solid before it reaches the gears
          G0 E-60 F300
          M117 Filament unloaded!
          RESTORE_GCODE_STATE NAME=unload_state
        ";
        "gcode_macro M600".gcode = "
          {% set X = params.X|default(50)|float %}
          {% set Y = params.Y|default(0)|float %}
          {% set Z = params.Z|default(10)|float %}
          SAVE_GCODE_STATE NAME=M600_state
          PAUSE
          G91
          G1 E-.8 F2700
          G1 Z{Z}
          G90
          G1 X{X} Y{Y} F3000
          G91
          G1 E-50 F1000
          RESTORE_GCODE_STATE NAME=M600_state
      ";
      "gcode_macro Z_Offset".gcode = "
        M117 Heating bed & nozzle...
        M104 S{150}
        M190 S{params.BED_TEMP|default(60, true)}
        G28
        TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM={params.BED_TEMP|default(60, true)}
        PROBE_CALIBRATE
      ";
      "pause_resume" = { };
      "gcode_macro CANCEL_PRINT" = {
        description = "Cancel the actual running print";
        rename_existing = "CANCEL_PRINT_BASE";
        variable_park = "True";
        gcode = "
          {% if printer.pause_resume.is_paused|lower == 'false' and park|lower == 'true'%}
            _TOOLHEAD_PARK_PAUSE_CANCEL
          {% endif %}
          TURN_OFF_HEATERS
          M106 S0
          CANCEL_PRINT_BASE
          M84
        ";
      };    
    };
    pico_usb_adxl = {
      "mcu pico".serial =
        "/dev/serial/by-id/usb-Klipper_rp2040_E661640843323828-if00";
      adxl345 = {
        spi_bus = "spi0a";
        cs_pin = "pico:gpio1";
      };
      resonance_tester = {
        accel_chip = "adxl345";
        probe_points = "110, 110, 60";
      };
      "gcode_macro GENERATE_SHAPER_GRAPHS" = {
        description =
          "Genarates input shaper resonances graphs for analysis. Uses the AXIS parameter for if you only want to do one axis at a time, (eg. GENERATE_SHAPER_GRAPHS AXIS=X)";
        gcode = "
          % if params.AXIS is defined %}
              {% if params.AXIS|lower == 'x' %}
                  G28
                  TEST_RESONANCES AXIS=X
                  RESPOND MSG=\"Input shaper graph generated for the X axis\"
              {% elif params.AXIS|lower == 'y' %}
                  G28
                  TEST_RESONANCES AXIS=Y
                  RESPOND MSG=\"Input shaper graph generated for the Y axis\"
              {% else %}
                  {action_raise_error(\"Unknown axis specified. Expected X or Y.\")}
              {% endif %}
          {% else %}
              G28
              TEST_RESONANCES AXIS=X
              TEST_RESONANCES AXIS=Y
          {% endif %}
        ";
      };
    };
    print_start_end = {
      "gcode_macro START_PRINT".gcode = "
        {% set BED = params.BED|default(60)|float %}
        {% set EXTRUDER = params.EXTRUDER|default(190)|float %}
        M104 S{EXTRUDER}
        M140 S{BED}
        G28
        M109 S{EXTRUDER}
        M190 S{BED}
        BED_MESH_PROFILE LOAD=SV06_mesh
        G28 Z
        G90 ; use absolute coordinates
        M83 ; extruder relative mode
        G1 Z0.2 F720
        G1 Y-3 F1000 ; go outside print area
        G92 E0
        G1 X60 E6 F1000 ; intro line
        G1 X100 E6 F1000 ; intro line
      ";
      "gcode_macro END_PRINT".gcode = "
        M400                           
        G92 E0                         
        G1 E-6.0 F3600               
        G91                           
        {% set max_x = printer.configfile.config[\"stepper_x\"][\"position_max\"]|float %}
        {% set max_y = printer.configfile.config[\"stepper_y\"][\"position_max\"]|float %}
        {% set max_z = printer.configfile.config[\"stepper_z\"][\"position_max\"]|float %}
        {% if printer.toolhead.position.x < (max_x - 20) %}
            {% set x_safe = 20.0 %}
        {% else %}
            {% set x_safe = -20.0 %}
        {% endif %}
        {% if printer.toolhead.position.y < (max_y - 20) %}
            {% set y_safe = 20.0 %}
        {% else %}
            {% set y_safe = -20.0 %}
        {% endif %}
        {% if printer.toolhead.position.z < (max_z - 2) %}
            {% set z_safe = 2.0 %}
        {% else %}
            {% set z_safe = max_z - printer.toolhead.position.z %}
        {% endif %}

        G0 Z{z_safe} F3600            
        G0 X{x_safe} Y{y_safe} F20000 
        TURN_OFF_HEATERS
        M107 ; turn off fan
        G90 ; use absolute coordinates
        G0 X5 Y{max_y} F3600       
        M84 ; disable motors
      ";
    };
    raspberry = {
      "temperature_sensor Raspberry" = {
        sensor_type = "temperature_host";
        min_temp = 0;
        max_temp = 80;
      };
    };
    screws_adjust = {
      screws_tilt_adjust = {
        screw1 = "85,136.5";
        screw1_name = "center";
        screw2 = "0.1,51.5";
        screw2_name = "front left";
        screw3 = "170.1,51.5";
        screw3_name = "front right";
        screw4 = "170.1,221.5";
        screw4_name = "back right";
        screw5 = "0.1,221.5";
        screw5_name = "back left";
        horizontal_move_z = 10;
        speed = 100;
        screw_thread = "CCW-M4";
      };
      "gcode_macro screws_adjust".gcode = "
        M117 Tilting...
        SCREWS_TILT_CALCULATE
      ";
    };
  };
  drivers = rec {
    _ = {
      "tmc2209 stepper_x" = {
        uart_pin = "PC1";
        diag_pin = "PA5";
        run_current = 0.86;
        sense_resistor = 0.15;
        uart_address = 3;
        driver_SGTHRS = 75;
      };
      "tmc2209 stepper_y" = {
        uart_pin = "PC0";
        diag_pin = "PA6";
        run_current = 0.9;
        sense_resistor = 0.15;
        uart_address = 3;
        driver_SGTHRS = 75;
      };
      "tmc2209 stepper_z" = {
        uart_pin = "PA15";
        run_current = 1.0;
        sense_resistor = 0.15;
        uart_address = 3;
      };
      "tmc2209 extruder" = {
        uart_pin = "PC14";
        run_current = 0.55;
        sense_resistor = 0.15;
        uart_address = 3;
      };
    };
    basic = lib.recursiveUpdate _ {
      "tmc2209 stepper_x" = {
        stealthchop_threshold = 1;
        interpolate = false;
      };
      "tmc2209 stepper_y" = {
        stealthchop_threshold = 1;
        interpolate = false;
      };
      "tmc2209 stepper_z" = {
        stealthchop_threshold = 1;
        interpolate = false;
      };
      "tmc2209 extruder" = {
        stealthchop_threshold = 0;
        interpolate = false;
      };
    };
    performance = lib.recursiveUpdate _ {
      "tmc2209 stepper_x" = {
        run_current = 1.0;
        stealthchop_threshold = 1;
        interpolate = false;
        driver_SGTHRS = 70;
      };
      "tmc2209 stepper_y" = {
        run_current = 1.0;
        stealthchop_threshold = 1;
        interpolate = false;
        driver_SGTHRS = 65;
      };
      "tmc2209 stepper_z" = {
        run_current = 1.0;
        stealthchop_threshold = 1;
        interpolate = false;
      };
      "tmc2209 extruder" = {
        run_current = 0.55;
        stealthchop_threshold = 0;
        interpolate = false;
      };
    };
    stealth = lib.recursiveUpdate _ {
      "tmc2209 stepper_x" = {
        run_current = 0.7;
        stealthchop_threshold = 999999;
        interpolate = false;
      };
      "tmc2209 stepper_y" = {
        run_current = 0.7;
        stealthchop_threshold = 999999;
        interpolate = false;
      };
      "tmc2209 stepper_z" = {
        run_current = 1.0;
        stealthchop_threshold = 999999;
        interpolate = false;
      };
      "tmc2209 extruder" = {
        run_current = 0.55;
        stealthchop_threshold = 0;
        interpolate = false;
      };
    };
  };
  steppers = rec {
    _ = {
      extruder = {
        microsteps = 32;
        max_extrude_only_distance = 100;
        step_pin = "PB4";
        dir_pin = "!PB3";
        enable_pin = "!PC3";
        filament_diameter = 1.75;
        heater_pin = "PA1";
        sensor_type = "sovol_thermistor";
        sensor_pin = "PC5";
        min_temp = 0;
        max_temp = 280;
        pressure_advance = 3.5e-2;
        pressure_advance_smooth_time = 4.0e-2;
      };
      stepper_x = {
        step_pin = "PC2";
        dir_pin = "!PB9";
        enable_pin = "!PC3";
        rotation_distance = 40;
        endstop_pin = "tmc2209_stepper_x:virtual_endstop";
        position_endstop = 0;
        position_max = 225;
        homing_speed = 30;
        homing_retract_dist = 0;
      };
      stepper_y = {
        step_pin = "PB8";
        dir_pin = "PB7";
        enable_pin = "!PC3";
        rotation_distance = 40;
        endstop_pin = "tmc2209_stepper_y:virtual_endstop";
        position_endstop = -5;
        position_min = -5;
        position_max = 220;
        homing_speed = 30;
        homing_retract_dist = 0;
      };
      stepper_z = {
        step_pin = "PB6";
        dir_pin = "!PB5";
        enable_pin = "!PC3";
        rotation_distance = 4;
        endstop_pin = "probe:z_virtual_endstop";
        position_min = -3;
        position_max = 259;
        homing_speed = 5;
      };
      safe_z_home = {
        home_xy_position = "85,136.5";
        z_hop = 10;
        z_hop_speed = 5;
      };
    };
    basic = lib.recursiveUpdate _ {
      stepper_x = { microsteps = 64; };
      stepper_y = { microsteps = 64; };
      stepper_z = { microsteps = 64; };
    };
    performance = lib.recursiveUpdate _ {
      stepper_x = { microsteps = 32; };
      stepper_y = { microsteps = 32; };
      stepper_z = { microsteps = 32; };
    };
    stealth = lib.recursiveUpdate _ {
      stepper_x = { microsteps = 16; };
      stepper_y = { microsteps = 16; };
      stepper_z = { microsteps = 16; };
    };
  };
  profiles = {
    basic = merge [
      steppers.basic
      drivers.basic
      {
        printer = {
          max_velocity = 180;
          max_accel = 800;
          max_z_velocity = 10;
          max_z_accel = 120;
          square_corner_velocity = 5;
        };
        bed_mesh = {
          speed = 150;
          horizontal_move_z = 2;
        };
        screws_tilt_adjust = { speed = 150; };
      }
    ];
    performance = merge [
      steppers.performance
      drivers.performance
      {
        printer = {
          max_velocity = 250;
          max_accel = 3000;
          max_accel_to_decel = 1500;
          max_z_velocity = 12;
          max_z_accel = 150;
          square_corner_velocity = 5;
        };
        bed_mesh = {
          speed = 200;
          horizontal_move_z = 2;
        };
        screws_tilt_adjust = { speed = 200; };
      }
    ];
    stealth = merge [
      steppers.stealth
      drivers.stealth
      {
        printer = {
          max_velocity = 130;
          max_accel = 400;
          max_accel_to_decel = 200;
          max_z_velocity = 5;
          max_z_accel = 100;
          square_corner_velocity = 5;
        };
        bed_mesh = {
          speed = 80;
          horizontal_move_z = 2;
        };
        screws_tilt_adjust = { speed = 80; };
      }
    ];
  };
in {
  services.moonraker = {
    enable = false;
    user = "root";
    address = "0.0.0.0";
    settings = {
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains =
          [ "*://*local" "*://app.fluidd.xyz" "*://my.mainsail.xyz" ];
        trusted_clients = [
          "10.0.0.0/8"
          "127.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "192.168.1.0/24"
          "FE80::/10"
          "::1/128"
        ];
      };
    };
  };
  services.fluidd = { enable = true; };
  services.klipper = {
    enable = true;
    user = "spaubleit";
    group = "users";
    # mutableConfig = true;
    # firmwares = {
    # mcu = {
    #   enable = true;
    #   configFile = ./avr.cfg;
    #   serial = serial;
    # };
    # };
    settings = merge [
      profiles.basic
      {
        mcu = {
          serial = serial;
          restart_method = "command";
        };
        printer = { kinematics = "cartesian"; };
        extruder = {
          nozzle_diameter = 0.6;
          rotation_distance = 4.63;
          control = "pid";
          pid_kp = 22.468;
          pid_ki = 1.762;
          pid_kd = 71.615;
        };
        probe = {
          # z_offset = 0;
          pin = "PB1";
          x_offset = 27.5;
          y_offset = -20;
          speed = 5;
          samples = 2;
          sample_retract_dist = 2;
          samples_tolerance = 0.01;
          samples_result = "median";
          samples_tolerance_retries = 5;
        };
        heater_bed = {
          heater_pin = "PA2";
          sensor_type = "EPCOS 100K B57560G104F";
          sensor_pin = "PC4";
          min_temp = 0;
          max_temp = 110;
          control = "pid";
          pid_kp = 70.609;
          pid_ki = 1.304;
          pid_kd = 955.866;
        };
        "thermistor sovol_thermistor" = {
          temperature1 = 25;
          resistance1 = 94162;
          beta = 4160;
        };
        fan.pin = "PA0";
        idle_timeout.timeout = 1800;
        virtual_sdcard.path = "/home/spaubleit/Printing/gcodes";
        # include mainsail cfg
        "menu __main __octoprint".type = "disabled";
        "bed_mesh SV06_mesh" = {
          version = 1;
          # increase bring distance down
          points = "
            -0.352031, -0.208125, -0.088125, -0.033281, -0.054063
            -0.345156, -0.200625, -0.088438, -0.066094, -0.103125
            -0.379531, -0.228750, -0.087969, -0.054844, -0.090938
            -0.324844, -0.188438, -0.082969, -0.040469, -0.083281
            -0.290781, -0.143594, -0.019844, 0.008594, -0.053438
          ";
          x_count = 5;
          y_count = 5;
          mesh_x_pps = 2;
          mesh_y_pps = 2;
          algo = "bicubic";
          tension = 0.05;
          min_x = 28.0;
          max_x = 205.0;
          min_y = 23.0;
          max_y = 200.0;
        };
        probe.z_offset = 0.940; # increase bring distance down
      }
      functions.display
      functions.raspberry
      functions.macros
      functions.bed_mesh
      functions.screws_adjust
      functions.gantry_calibration
      functions.print_start_end
    ];
  };
}
