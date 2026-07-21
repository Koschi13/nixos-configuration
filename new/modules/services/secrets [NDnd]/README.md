# secrets

This module sets up `age` via `agenix`.
Secrets from `secrets/` can be accessed via `age.secrets.<filename>`.

## Example

Let's assume you have `secrets/homeserver-cred.age`, the import for an aspect
named `alpha` (class `nixos`) would then be:
```nix
{
  inputs,
  ...
}: {
  flake.modules.nixos.alpha = {...}: {
    age.secrets."homeserver-cred" = {
      file = "${inputs.secrets}/homeserver-cred.age";
    };
  };
}
```
