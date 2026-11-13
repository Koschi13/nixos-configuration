# Wiki

## self / inputs / self.inputs / inputs.self

This is a **flake-parts** flake, which is the key to the answer.

## Short version

In this file, `inputs` and `self.inputs` point to **the same thing** — they're two paths to the flake's inputs. The difference is _scope_ and _why each exists_:

- **`inputs`** — the module argument that flake-parts injects directly into every module. It's the top-level flake inputs (`nixpkgs`, `home-manager`, etc.).
- **`self`** — flake-parts' reference to your own flake's final output attrset. `self.inputs` is the standard attribute Nix attaches to a flake's `self`, containing that same set of inputs.

So `self.inputs.nixpkgs` ≡ `inputs.nixpkgs`. Both resolve to the `nixpkgs` input, declared in `modules/systems/1 - default [NDn]/flake-file.nix`.

## How they are used here

Two typical usages, from `hosts/alpha [N]/users/max.nix` and `formatter.nix`:

```nix
inherit (self) modules factory;                         # (a)
...
imports = [inputs.treefmt-nix.flakeModule];              # (b)
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
- `inputs.nixpkgs` — reach the input directly. `self.inputs.nixpkgs` is the same, going `self → inputs → nixpkgs`.

Both are valid because Nix makes the graph circular: `self.inputs.self.inputs.self...` all resolve. This repository uses the short forms: `self` for its own outputs and `inputs` for inputs.

## Secrets

The repository is public, so secrets are files in `secrets/*.age`, encrypted
with agenix. Their plaintext only exists in `/run/agenix` (tmpfs) and never in
the world-readable Nix store.

Agenix decrypts at activation, so Nix can't read a secret during evaluation.
Everything evaluated is public: to keep a value private, have a program read it
at runtime, e.g. the autofs map of `mount-homeserver` or the SSH `Include` of
`vw-ssm`.

### agenix

- `secrets/agenix-rules.nix` lists the public keys every secret is encrypted
  to: the admin age key and the SSH host key of every host.
- `secrets/README.md` documents what each secret contains and the format of
  its plaintext. A new secret gets a section there.
- `age.secrets.<name>.file` in a NixOS module decrypts the secret at
  activation with `/etc/ssh/ssh_host_ed25519_key` into
  `config.age.secrets.<name>.path` (`/run/agenix/<name>`), with the given
  `owner` and `mode`. Home-Manager aspects read the path through
  `osConfig.age.secrets.<name>.path`.
- The admin age key is wrapped with the GPG key of the YubiKey in
  `keys/admin.key.gpg`. `scripts/secret-edit.sh` unwraps it into
  `$XDG_RUNTIME_DIR` and runs `agenix` with it:
  - `scripts/secret-edit.sh -e <name>.age` edits or creates a secret, add it
    to `agenix-rules.nix` first
  - `scripts/secret-edit.sh -r` re-encrypts every secret, e.g. after adding a
    host key
- Binary files: `scripts/secret-edit.sh -e <name>.age < <file>` (agenix reads
  stdin when it isn't a terminal).

The `secrets-guard` git hook (`modules/formatter.nix`) refuses commits with
unencrypted files in `secrets/` or `keys/`.

Backups: `keys/admin.key.gpg` only opens with the YubiKey, so keep the
plaintext admin key (`gpg -d keys/admin.key.gpg`) in the password manager. A
lost host gets a new host key: add it to `agenix-rules.nix` and run
`scripts/secret-edit.sh -r`.
