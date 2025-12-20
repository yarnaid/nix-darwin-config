{pkgs, ...}: {
  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;
    
    settings = {
      # Basic settings
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 300;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      automatically-unhide-macos-hidden-apps = false;
      after-startup-command = [
      "exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0"
      ];

      # Key mapping
      key-mapping = {
        preset = "qwerty";
      };

      # Gaps configuration
      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          left = 10;
          bottom = 10;
          right = 40;
          top = [
            { monitor."LG HDR 4K" = 0; }
            { monitor."HDMI" = 0; }
            { monitor."Retina" = 0; }
            0
          ];
        };
      };

      # Mode configurations
      mode = {
        main.binding = {
          "alt-slash" = "layout tiles horizontal vertical";
          "alt-comma" = "layout accordion horizontal vertical";
          
          # Focus controls
          "alt-h" = "focus left";
          "alt-j" = "focus down";
          "alt-k" = "focus up";
          "alt-l" = "focus right";
          
          # Move controls
          "alt-shift-h" = "move left";
          "alt-shift-j" = "move down";
          "alt-shift-k" = "move up";
          "alt-shift-l" = "move right";
          
          # Resize controls
          "alt-minus" = "resize smart -50";
          "alt-equal" = "resize smart +50";
          
          # Fullscreen
          "alt-cmd-f" = "fullscreen";
          
          # Workspace switching
          "alt-1" = "workspace 1";
          "alt-2" = "workspace 2";
          "alt-3" = "workspace 3";
          "alt-4" = "workspace 4";
          "alt-5" = "workspace 5";
          "alt-6" = "workspace 6";
          "alt-7" = "workspace 7";
          "alt-8" = "workspace 8";
          "alt-9" = "workspace 9";
          "alt-q" = "workspace Q";
          "alt-w" = "workspace W";
          "alt-e" = "workspace E";
          "alt-r" = "workspace R";
          "alt-a" = "workspace A";
          "alt-s" = "workspace S";
          "alt-d" = "workspace D";
          # "alt-f" = "workspace F";
          "alt-z" = "workspace Z";
          "alt-x" = "workspace X";
          "alt-c" = "workspace C";
          "alt-v" = "workspace V";
          
          # Move to workspace
          "alt-shift-1" = "move-node-to-workspace 1";
          "alt-shift-2" = "move-node-to-workspace 2";
          "alt-shift-3" = "move-node-to-workspace 3";
          "alt-shift-4" = "move-node-to-workspace 4";
          "alt-shift-5" = "move-node-to-workspace 5";
          "alt-shift-6" = "move-node-to-workspace 6";
          "alt-shift-7" = "move-node-to-workspace 7";
          "alt-shift-8" = "move-node-to-workspace 8";
          "alt-shift-9" = "move-node-to-workspace 9";
          "alt-shift-q" = "move-node-to-workspace Q";
          "alt-shift-w" = "move-node-to-workspace W";
          "alt-shift-e" = "move-node-to-workspace E";
          "alt-shift-r" = "move-node-to-workspace R";
          "alt-shift-a" = "move-node-to-workspace A";
          "alt-shift-s" = "move-node-to-workspace S";
          "alt-shift-d" = "move-node-to-workspace D";
          # "alt-shift-f" = "move-node-to-workspace F";
          "alt-shift-z" = "move-node-to-workspace Z";
          "alt-shift-x" = "move-node-to-workspace X";
          "alt-shift-c" = "move-node-to-workspace C";
          "alt-shift-v" = "move-node-to-workspace V";
          
          # Other controls
          "alt-tab" = "workspace-back-and-forth";
          "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";
          "alt-shift-semicolon" = "mode service";
        };

        service.binding = {
          "esc" = ["reload-config" "mode main"];
          "r" = ["flatten-workspace-tree" "mode main"];
          "f" = ["layout floating tiling" "mode main"];
          # "backspace" = ["close-all-windows-but-current" "mode main"];
          "alt-shift-h" = ["join-with left" "mode main"];
          "alt-shift-j" = ["join-with down" "mode main"];
          "alt-shift-k" = ["join-with up" "mode main"];
          "alt-shift-l" = ["join-with right" "mode main"];
          "down" = "volume down";
          "up" = "volume up";
          "shift-down" = ["volume set 0" "mode main"];
        };
      };

      workspace-to-monitor-force-assignment = {
        # "W" = "Built-in Retina Display";
        # "E" = "TYPE-C";
      };

      # Window detection rules
      on-window-detected = [
      {
        "if" = {
          app-id = "com.kagi.kagimacOS";
        };
        run = "move-node-to-workspace Q";
      }
      {
        "if" = {
          app-id = "company.thebrowser.Browser";
        };
        run = "move-node-to-workspace Q";
      }

      {
        "if" = {
          app-id = "ch.protonmail.desktop";
        };
        run = "move-node-to-workspace W";
      }
      {
        "if" = {
          app-id = "io.canarymail.mac";
        };
        run = "move-node-to-workspace W";
      }
      {
        "if" = {
          app-id = "com.microsoft.Outlook";
        };
        run = "move-node-to-workspace W";
      }


      {
        "if" = {
          app-id = "com.microsoft.teams2";
        };
        run = "move-node-to-workspace E";
      }
      {
        "if" = {
          app-id = "ru.keepcoder.Telegram";
        };
        run = "move-node-to-workspace E";
      }

      {
        "if" = {
          app-id = "io.readwise.read";
        };
        run = "move-node-to-workspace R";
      }


      {
        "if" = {
          app-id = "com.todesktop.230313mzl4w4u92";
        };
        run = "move-node-to-workspace A";
      }
      {
        "if" = {
          app-id = "com.microsoft.VSCode";
        };
        run = "move-node-to-workspace A";
      }
      {
        "if" = {
          app-id = "com.google.antigravity";
        };
        run = "move-node-to-workspace A";
      }


      {
        "if" = {
          app-id = "com.mitchellh.ghostty";
        };
        run = "move-node-to-workspace S";
      }
      {
        "if" = {
          app-id = "com.googlecode.iterm2";
        };
        run = "move-node-to-workspace S";
      }
      {
        "if" = {
          app-id = "com.apple.ActivityMonitor";
        };
        run = "move-node-to-workspace D";
      }



      {
        "if" = {
          app-id = "inc.tana.desktop";
        };
        run = "move-node-to-workspace Z";
      }
      {
        "if" = {
          app-id = "com.culturedcode.ThingsMac";
        };
        run = "move-node-to-workspace Z";
      }

      {
        "if" = {
          app-id = "ru.yandex.desktop.music";
        };
        run = "move-node-to-workspace X";
      }
      {
        "if" = {
          app-id = "com.spotify.client";
        };
        run = "move-node-to-workspace X";
      }
      {
        "if" = {
          app-id = "com.apple.Music";
        };
        run = "move-node-to-workspace X";
      }


      {
        "if" = {
          app-id = "com.microsoft.rdc.macos";
        };
        run = "move-node-to-workspace C";
      }
        # {
        #   "if" = {
        #     app-id = "com.apple.Safari";
        #   };
        #   run = "move-node-to-workspace W";
        # }
        # {
        #   "if" = {
        #     app-id = "inc.tana.desktop";
        #     during-aerospace-startup = true;
        #   };
        #   run = "move-node-to-workspace T";
        #   check-further-callbacks = true;
        # }
        # {
        #   "if" = {
        #     app-id = "com.culturedcode.ThingsMac";
        #   };
        #   run = "move-node-to-workspace T";
        # }
      ];
    };
  };
} 
