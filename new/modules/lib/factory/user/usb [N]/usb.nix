{
  config.flake.factory.gaming = username: {
    nixos.${username} = {
      services.devmon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;

      users.users.${username}.extraGroups = ["usb"];
    };
  };
}
