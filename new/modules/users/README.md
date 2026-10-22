# users

Configuration per user, one directory per user.

- `<user> [<tag>]/<user>.nix` creates the user via the `user` factory and defines the
  `homeManager.<user>` aspect, which holds everything the user wants on every
  host.

Hosts pick their users in `hosts/<host>/users/`. That is also the place for
host specific user configuration, set via
`home-manager.users.<user>` inside the `nixos.<host>` aspect.

Aspects that have to configure every user of a host, like `audio` or `gaming`,
add groups through the `dotfiles.userGroups` option instead of being
instantiated per user.
