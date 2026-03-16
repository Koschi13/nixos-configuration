{
  lib,
  rootPath,
  ...
}: let
  vars = import "${rootPath}/.secrets/ssm_vars.nix";
  regionProfile = "--region ${vars.region} --profile ${vars.profile}";
  proxyCommand = "sh -c \"aws ec2 start-instances ${regionProfile} --instance-ids %h && aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' ${regionProfile}\"";

  sshAttrs =
    builtins.listToAttrs
    (map (host: {
        name = host.name;
        value = {
          hostname = host.hostname;
          user = vars.user;
          proxyCommand = proxyCommand;
        };
      })
      vars.hosts);
  serviceListAttrs = map (host:
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
    host.services)
  vars.hosts;
  serviceAttrs = builtins.listToAttrs (lib.lists.flatten serviceListAttrs);
in {
  programs.ssh = {
    matchBlocks = sshAttrs // serviceAttrs;
  };

  home.sessionVariables = builtins.listToAttrs (map (host: {
      name = host.name;
      value = host.hostname;
    })
    vars.hosts);
}
