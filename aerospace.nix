{pkgs, ...}: {
  services.aerospace = {
    enable = false;
    package = pkgs.aerospace;
    
    settings = {
      # Basic settings
      # start-at-login = true;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 300;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      automatically-unhide-macos-hidden-apps = false;

      # Key mapping
      key-mapping = {
        preset = "qwerty";
      };

      # Gaps configuration
      gaps = {
        inner = {
          horizontal = 0;
          vertical = 0;
        };
        outer = {
          left = 0;
          bottom = 0;
          right = 0;
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
          "alt-a" = "workspace A";
          "alt-c" = "workspace C";
          "alt-d" = "workspace D";
          "alt-f" = "workspace F";
          "alt-m" = "workspace M";
          "alt-s" = "workspace S";
          "alt-t" = "workspace T";
          "alt-w" = "workspace W";
          
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
          "alt-shift-a" = "move-node-to-workspace A";
          "alt-shift-c" = "move-node-to-workspace C";
          "alt-shift-d" = "move-node-to-workspace D";
          "alt-shift-f" = "move-node-to-workspace F";
          "alt-shift-m" = "move-node-to-workspace M";
          "alt-shift-s" = "move-node-to-workspace S";
          "alt-shift-t" = "move-node-to-workspace T";
          "alt-shift-w" = "move-node-to-workspace W";
          
          # Other controls
          "alt-tab" = "workspace-back-and-forth";
          "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";
          "alt-shift-semicolon" = "mode service";
        };

        service.binding = {
          "esc" = ["reload-config" "mode main"];
          "r" = ["flatten-workspace-tree" "mode main"];
          "f" = ["layout floating tiling" "mode main"];
          "backspace" = ["close-all-windows-but-current" "mode main"];
          "alt-shift-h" = ["join-with left" "mode main"];
          "alt-shift-j" = ["join-with down" "mode main"];
          "alt-shift-k" = ["join-with up" "mode main"];
          "alt-shift-l" = ["join-with right" "mode main"];
          "down" = "volume down";
          "up" = "volume up";
          "shift-down" = ["volume set 0" "mode main"];
        };
      };

      # Window detection rules
      on-window-detected = [
        {
          "if" = {
            app-id = "com.apple.Safari";
          };
          run = "move-node-to-workspace W";
        }
        {
          "if" = {
            app-id = "com.google.Chrome";
          };
          run = "move-node-to-workspace W";
        }
        {
          "if" = {
            app-id = "co.podzim.BoltGPT-setapp";
          };
          run = "move-node-to-workspace A";
        }
        {
          "if" = {
            app-id = "inc.tana.desktop";
            during-aerospace-startup = true;
          };
          run = "move-node-to-workspace T";
          check-further-callbacks = true;
        }
        {
          "if" = {
            app-id = "com.culturedcode.ThingsMac";
          };
          run = "move-node-to-workspace T";
        }
        {
          "if" = {
            app-id = "com.deezer.deezer-desktop";
          };
          run = "move-node-to-workspace M";
        }
        {
          "if" = {
            app-id = "ru.keepcoder.Telegram";
          };
          run = "move-node-to-workspace C";
        }
        {
          "if" = {
            app-id = "com.readdle.SparkDesktop-setapp";
          };
          run = "move-node-to-workspace C";
        }
        {
          "if" = {
            app-id = "io.zsa.keymapp";
          };
          run = "move-node-to-workspace 11";
        }
      ];
    };
  };
} 
