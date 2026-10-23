{inputs, ...}: let
  # The `agenix` CLI to edit the secrets of `secrets/secrets.nix`, see
  # `scripts/secret-edit.sh`
  agenix-cli = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.age
    ];
  };
in {
  # Decrypts `age.secrets.<name>` with the SSH host key at activation, into
  # /run/agenix/<name>. The plaintext never ends up in the Nix store.
  flake.modules.nixos.agenix = {
    imports = [
      inputs.agenix.nixosModules.default
      agenix-cli
    ];
    # Use a custom path, so this module doesn't rely on openssh being enabled.
    age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  flake.modules.darwin.agenix = {
    imports = [
      inputs.agenix.darwinModules.default
      agenix-cli
    ];
    # Use a custom path, so this module doesn't rely on openssh being enabled.
    age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
