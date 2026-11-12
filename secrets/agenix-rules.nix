# The rules of the `agenix` CLI: which public keys every secret is encrypted
# to. Only the CLI reads this file, the system configuration does not import
# it. Edit secrets with `scripts/secret-edit.sh -e <name>.age` and re-encrypt
# all of them after changing the keys with `scripts/secret-edit.sh -r`. What
# each secret contains is documented in `README.md` next to this file.
let
  # Age key for editing, wrapped with the GPG key of the YubiKey in
  # keys/admin.key.gpg
  admin = "age1x93tjr8qujt7jpwy5fvrk9v2lhs93al5rztnek9k2pwdsum0ratsq3q8td";

  # SSH host keys, used to decrypt the secrets at activation
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqI79RLKudDEM66IiZe6GtUA4oh2mYZDQPeLShv3aBf";
  epsilon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0VjsO3RogO7FHlyg/zyT1qJJnPDRGOvRA3DLkgbm0U";
  fabricator = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDVZJEOQsUk7aw6/tSCz9ezBbJL71KrzGAeB20vDFF4";

  all = [admin alpha epsilon];
in {
  "smb-credentials.age".publicKeys = all;
  "git-hiq.age".publicKeys = [admin epsilon];
  "firefly-iii-app-key.age".publicKeys = [admin fabricator];
  "glance-env.age".publicKeys = [admin fabricator];
  "greeter-wallpaper.jpg.age".publicKeys = all;
  "homeserver-map.age".publicKeys = [admin alpha];
  "pgadmin-password.age".publicKeys = [admin fabricator];
  "postgresql-admin-password.age".publicKeys = [admin fabricator];
  "restic-fabricator-password.age".publicKeys = [admin fabricator];
  "restic-fabricator-ssh-config.age".publicKeys = [admin fabricator];
  "restic-fabricator-ssh-key.age".publicKeys = [admin fabricator];
  "vw-ssh-config.age".publicKeys = [admin epsilon];
}
