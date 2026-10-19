# factory

Factories are functions producing configuration for a given name, so the same
setup can be instantiated per host or per user. They are stored in
`flake.factory` (see `factory.nix`) and called through `self.factory.<name>`.

| Factory            | Arguments                                 | Returns                     |
| ------------------ | ----------------------------------------- | --------------------------- |
| `luks`             | `hostname`, `uuid`, `ssd`                 | `flake.modules` fragment    |
| `greetd`           | `hostname`, `username`, `windowManager`   | `flake.modules` fragment    |
| `user`             | `username`, `uid`, `isAdmin`              | `flake.modules` fragment    |
| `mount-homeserver` | `username`                                | NixOS module                |

There are two return shapes:

- **`flake.modules` fragments** define aspects like `nixos.<hostname>`. Merge
  them with the other modules of the file:

  ```nix
  flake.modules = lib.mkMerge [
    (self.factory.luks {...})
    {nixos.alpha = {...};}
  ];
  ```

- **Modules** are imported into an existing aspect:

  ```nix
  flake.modules.nixos.alpha = {
    imports = [(self.factory.mount-homeserver {username = "max";})];
  };
  ```

The arguments and an example of each factory are documented next to its
implementation.
