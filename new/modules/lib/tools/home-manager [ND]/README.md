# home-manager

Wires `Home-Manager` into the `nixos` and `darwin` classes, so that you can
build your system and Home-Manager together.

It defines:
- `flake.modules.nixos.home-manager` and `flake.modules.darwin.home-manager`
  aspects that bring the Home-Manager NixOS/Darwin module (and shared config)
  into a system. Hosts must import these to use them.
  *They are made available, not auto-enabled.*
- `flake.modules.homeManager.<aspect>`, the Home-Manager *module class*, holding
  system generic configurations for `Home-Manager`.

To summarize, there is:
```nix
flake.modules."<nixos/darwin>"."<hostname>".home-manager.users."<username>"
```

for host specific Home-Manager changes and
```nix
flake.modules.homeManager."<username>"
```

The first is specific to `nixos` or `darwin` while the latter is generic for
both.
