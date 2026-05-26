{
  pkgs,
  rootPath,
  ...
}: let
  vars = import "${rootPath}/.secrets/ssm_vars.nix";

  # list[list[{host; service;}]]
  regions = map (config: let
    regionProfile = "--region ${config.region} --profile ${vars.profile}";
    startInstanceCommand = "aws ec2 start-instances ${regionProfile} --instance-ids %h";
    waitForInstanceCommand = "aws ec2 wait instance-status-ok ${regionProfile} --instance-ids %h";
    startSessionCommand = "aws ssm start-session  ${regionProfile} --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'";
    proxyCommand = "sh -c \"${startInstanceCommand} && ${waitForInstanceCommand} && ${startSessionCommand}\"";
  in
    map (host: {
      # list
      host = {
        name = host.name;
        value = {
          hostname = host.hostname;
          user = vars.user;
          identityFile = host.identityFile;
          proxyCommand = proxyCommand;
        };
      };

      # list[list]
      services =
        map (service: {
          name = "${host.name}_${service.name}";
          value = {
            hostname = host.hostname;
            user = vars.user;
            identityFile = host.identityFile;
            localForwards = [
              {
                bind.port = 8080;
                host.port = service.port;
                host.address = service.address;
              }
            ];
            proxyCommand = proxyCommand;
          };
        })
        host.services;
    })
    config.hosts)
  vars.regions;

  hostAttrs = builtins.listToAttrs (builtins.concatLists (map (regionConfigs: map (config: config.host) regionConfigs) regions));
  serviceAttrs = builtins.listToAttrs (builtins.concatLists (map (regionConfigs: builtins.concatLists (map (config: config.services) regionConfigs)) regions));
in {
  programs.ssh = {
    settings = hostAttrs // serviceAttrs;
  };

  home = {
    sessionVariables = builtins.listToAttrs (builtins.concatLists (map (config:
      map (host: {
        name = host.name;
        value = host.hostname;
      })
      config.hosts)
    vars.regions));

    packages = [
      pkgs.sshuttle
    ];
  };
}
