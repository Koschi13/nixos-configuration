# Temporary workaround for out-of-tree kernel modules failing to build since
# nixpkgs started signing modules with kmodigest (nixpkgs 02c087f). Delete this
# file once `nh os boot .#` builds without it.
#
# Related upstream issue: https://github.com/NixOS/nixpkgs/issues/575192
{
  flake.modules.nixos.epsilon = {
    nixpkgs.overlays = [
      (_final: prev: {
        linuxPackages = prev.linuxPackages.extend (_kfinal: kprev: {
          tuxedo-drivers = kprev.tuxedo-drivers.overrideAttrs (old: {
            # The kernel make flags now contain `cmd_sign=...$(space)$@`. The
            # Makefile pastes $(MAKEFLAGS) into a shell command, where bash
            # chokes on `$(space)`. make passes the flags on by itself anyway.
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace Makefile --replace-fail " \$(MAKEFLAGS)" ""
              '';
            # See v4l2loopback below
            makeFlags = old.makeFlags ++ ["DEPMOD=true"];
          });

          # modules_install now runs depmod into the package output, whose
          # `modules.*` files collide with the kernel's when all modules are
          # merged (aggregateModules). The merge reruns depmod anyway.
          v4l2loopback = kprev.v4l2loopback.overrideAttrs (old: {
            makeFlags = old.makeFlags ++ ["DEPMOD=true"];
          });
        });
      })
    ];
  };
}
