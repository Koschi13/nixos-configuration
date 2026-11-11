# secrets

The secrets of all hosts, encrypted with agenix. This file describes what each
one contains and what its plaintext has to look like. Which keys can decrypt
them is in `agenix-rules.nix`, how agenix works in the Secrets section of
`WIKI.md`.

Edit a secret with `scripts/secret-edit.sh -e <name>.age`, a binary one with
`scripts/secret-edit.sh -e <name>.age < <file>`. A new secret goes into
`agenix-rules.nix` first and gets a section here.

## Homeserver shares

### `homeserver-map`

The SMB shares of the homeserver as autofs direct map, one line each. A
secret, to keep the server and share names out of the repository. autofs
appends the mount options of the master map to them.

```
<mount path> -credentials=/run/agenix/smb-credentials ://<server>/<share>
```

### `smb-credentials`

The login of the shares. Always decrypted to `/run/agenix/smb-credentials`, as
`homeserver-map` refers to that path.

```
username=<user>
password=<password>
```

## Desktop

### `greeter-wallpaper.jpg`

A JPEG, the background of the SDDM login screen. Encrypted for copyright
reasons. Binary, so edit it with
`scripts/secret-edit.sh -e greeter-wallpaper.jpg.age < <file>.jpg`.

### `glance-env`

The environment of the Glance service, keeping the location out of the
repository.

```
GLANCE_LOCATION=<city>, <country>
```

## Work (HiQ)

### `git-hiq`

A git config with the work identity, used for the repositories of HiQ. A
secret, to keep the work email out of the repository.

```ini
[user]
  name = <name>
  email = <work email>
```

### `vw-ssh-config`

An SSH config with the `Host` blocks of the VW AWS hosts, reached through the
SSM session manager. A secret, as the host names are internal.

```
Host <name>
  …
```
