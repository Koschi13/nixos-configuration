# Wiki

## self / inputs / self.inputs / inputs.self

This is a **flake-parts** flake, which is the key to the answer.

## Short version

In this file, `inputs` and `self.inputs` point to **the same thing** — they're two paths to the flake's inputs. The difference is _scope_ and _why each exists_:

- **`inputs`** — the module argument that flake-parts injects directly into every module. It's the top-level flake inputs (`nixpkgs`, `home-manager`, `git-crypt-secrets`, etc.).
- **`self`** — flake-parts' reference to your own flake's final output attrset. `self.inputs` is the standard attribute Nix attaches to a flake's `self`, containing that same set of inputs.

So `self.inputs.git-crypt-secrets` ≡ `inputs.git-crypt-secrets`. Both resolve to the `git-crypt-secrets` input (`path:../.secrets`), declared in `modules/programs/git-crypt [ND]/flake-file.nix`.

## How they are used here

Two typical usages, from `hosts/alpha [N]/users/max.nix` and `programs/git [nd]/git.nix`:

```nix
inherit (self) modules factory;                         # (a)
...
vars = import "${inputs.git-crypt-secrets}/git_vars.nix"; # (b)
```

There are actually **three** forms in play, and they chain like this:

| Expression    | What it is                                                                    |
| ------------- | ----------------------------------------------------------------------------- |
| `inputs`      | flake-parts module arg = the flake's inputs                                   |
| `self`        | flake-parts module arg = your flake's outputs                                 |
| `inputs.self` | the `self` entry _inside_ inputs (Nix adds `self` to every flake's input set) |
| `self.inputs` | the `inputs` entry _inside_ self (Nix adds `inputs` to every flake's `self`)  |

So:

- `self.modules` — reach _your own flake's_ `modules` output. `inputs.self.modules` is the same, going `inputs → self → modules`.
- `inputs.git-crypt-secrets` — reach the input directly. `self.inputs.git-crypt-secrets` is the same, going `self → inputs → git-crypt-secrets`.

Both are valid because Nix makes the graph circular: `self.inputs.self.inputs.self...` all resolve. This repository uses the short forms: `self` for its own outputs and `inputs` for inputs.
