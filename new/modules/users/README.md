# users

Configuration per user, one directory per user.

- `<user>/<user>.nix` creates the user via the `user` factory and defines the
  `homeManager.<user>` aspect.
- Further directories hold variants of the same user, for example
  `max/hiq` for the work setup.
- `default.nix` exposes the standalone Home-Manager configurations.

Hosts pick their users in `hosts/<host>/users/`. Aspects that have to
configure every user of a host, like `audio` or `gaming`, read the users from
the `dotfiles.users` option instead of being instantiated per user.
