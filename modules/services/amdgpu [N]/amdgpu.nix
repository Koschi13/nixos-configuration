{
  flake.modules = {
    nixos.amdgpu = {
      config,
      pkgs,
      ...
    }: {
      # GPU control daemon and GUI
      services.lact = {
        enable = true;
        # Declared here instead of the mutable /etc/lact/config.yaml, so stale
        # entries for removed cards can't pile up. Settings changed in the GUI
        # are not saved; tune them there and copy the values into this file.
        settings = {
          version = 7;
          daemon = {
            log_level = "info";
            admin_group = "wheel";
            disable_clocks_cleanup = false;
          };
          apply_settings_timer = 5;
          # Settings for the RX 6900 XT go under
          # "1002:73BF-1EAE:6901-0000:0b:00.0" (see `lact cli list`)
          gpus = {};
          current_profile = null;
          auto_switch_profiles = false;
        };
      };
      # Unlocks clock and voltage control, which lact needs for overclocking
      hardware.amdgpu.overdrive.enable = true;

      # When lactd applied its settings while the SDDM greeter (Weston) did its
      # first modesets, a DRM commit failed with EBUSY and Weston aborted,
      # leaving a blank TTY1 as SDDM doesn't restart a crashed greeter. So the
      # greeter only starts once lactd is done.
      systemd.services.lactd = {
        before = ["display-manager.service"];
        # lactd counts as started right away but applies the settings a moment
        # later. Waits until it answers, but at most 10s so a broken lactd
        # can't keep the login screen away.
        serviceConfig.ExecStartPost = "${pkgs.writeShellScript "lactd-wait-ready" ''
          for _ in $(${pkgs.coreutils}/bin/seq 50); do
            ${config.services.lact.package}/bin/lact cli list >/dev/null 2>&1 && exit 0
            ${pkgs.coreutils}/bin/sleep 0.2
          done
          exit 0
        ''}";
      };
    };
  };
}
