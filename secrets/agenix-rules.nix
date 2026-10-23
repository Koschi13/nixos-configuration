# The rules of the `agenix` CLI: which public keys every secret is encrypted
# to. Only the CLI reads this file, the system configuration does not import
# it. Edit secrets with `scripts/secret-edit.sh -e <name>.age` and re-encrypt
# all of them after changing the keys with `scripts/secret-edit.sh -r`.
let
  # Age key for editing, wrapped with the GPG key of the YubiKey in
  # keys/admin.key.gpg
  admin = "age1x93tjr8qujt7jpwy5fvrk9v2lhs93al5rztnek9k2pwdsum0ratsq3q8td";

  # SSH host keys, used to decrypt the secrets at activation
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqI79RLKudDEM66IiZe6GtUA4oh2mYZDQPeLShv3aBf";
  epsilon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0VjsO3RogO7FHlyg/zyT1qJJnPDRGOvRA3DLkgbm0U";

  all = [admin alpha epsilon];
in {
  "smb-credentials.age".publicKeys = all;
  "git-hiq.age".publicKeys = all;
  "glance-env.age".publicKeys = all;
  "greeter-wallpaper.jpg.age".publicKeys = all;
}
