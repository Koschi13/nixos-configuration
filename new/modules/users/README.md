# users

Configuration per user, one directory per user.

- `<user>/<user>.nix` creates the user via the `user` factory and defines the
  `homeManager.<user>` aspect, which holds everything the user wants on every
  host.
- `default.nix` exposes a standalone Home-Manager configuration for hosts
  without NixOS.

Hosts pick their users in `hosts/<host>/users/`. That is also the place for
host specific user configuration, set via
`home-manager.users.<user>` inside the `nixos.<host>` aspect.

Aspects that have to configure every user of a host, like `audio` or `gaming`,
read the users from the `dotfiles.users` option instead of being instantiated
per user.
