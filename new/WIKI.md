# Wiki

## self / inputs / self.inputs / inputs.self

This is a **flake-parts** flake, which is the key to the answer.

## Short version

In this file, `inputs` and `self.inputs` point to **the same thing** — they're two paths to the flake's inputs. The difference is _scope_ and _why each exists_:

- **`inputs`** — the module argument that flake-parts injects directly into every module. It's the top-level flake inputs (`agenix`, `nixpkgs`, `home-manager`, `secrets`, etc.).
- **`self`** — flake-parts' reference to your own flake's final output attrset. `self.inputs` is the standard attribute Nix attaches to a flake's `self`, containing that same set of inputs.

So `self.inputs.secrets` ≡ `inputs.secrets`. Both resolve to the `secrets` input (the non-flake `path:./secrets`) defined in `flake.nix:25`.

## Why both appear here

Look at the two usages in `max.nix`:

```nix
imports = with inputs.self.modules.nixos;     # (a)
          with inputs.self.factory; [ ... ];
...
file = "${self.inputs.secrets}/homeserver-cred.age";  # (b)
```

There are actually **three** forms in play, and they chain like this:

| Expression    | What it is                                                                    |
| ------------- | ----------------------------------------------------------------------------- |
| `inputs`      | flake-parts module arg = the flake's inputs                                   |
| `self`        | flake-parts module arg = your flake's outputs                                 |
| `inputs.self` | the `self` entry _inside_ inputs (Nix adds `self` to every flake's input set) |
| `self.inputs` | the `inputs` entry _inside_ self (Nix adds `inputs` to every flake's `self`)  |

So:

- `inputs.self.modules.nixos` — reach _your own flake's_ `modules.nixos` output, going `inputs → self → modules`.
- `self.inputs.secrets` — reach the `secrets` _input_, going `self → inputs → secrets`.

Both are valid because Nix makes the graph circular: `self.inputs.self.inputs.self...` all resolve. You could equally have written `inputs.secrets` and `self.modules.nixos` and gotten identical results.
