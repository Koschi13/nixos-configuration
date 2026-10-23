# firmware

Installs all available firmware, including unfree blobs, and enables `fwupd`
to update device firmware (UEFI/BIOS, SSDs, docks, peripherals).

Updates are never applied automatically. To update:

```sh
fwupdmgr refresh   # fetch the latest metadata
fwupdmgr get-updates
fwupdmgr update    # may ask for a reboot
```

`fwupdmgr get-devices` lists what `fwupd` can manage on this host.
