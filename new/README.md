# My Nix(OS) Configuration

## Dendritic

- host
  - services
  - user
    - programs

### Directory tags

Aspect directories carry a tag listing the classes they configure, so the
supported platforms are visible without opening the files:

| Tag | Class                            |
| --- | -------------------------------- |
| `N` | `nixos`                          |
| `D` | `darwin`                         |
| `n` | `homeManager` on Linux           |
| `d` | `homeManager` on macOS           |

For example `shell [NDnd]` configures every class, while `rofi [n]` only
exists for Home-Manager on Linux. `[]` marks flake-parts only modules.

## Docs

Functions are documented using the
[nixdoc](https://github.com/nix-community/nixdoc) syntax.

## Inspiration

- https://github.com/NotAShelf/nyx
- https://github.com/Doc-Steve/dendritic-design-with-flake-parts
- https://flake.parts/
