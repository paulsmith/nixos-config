{
  pkgs,
  username,
  ...
}: {
  launchd.user.agents.runsvdir = {
    serviceConfig = {
      Label = "org.nixos.runsvdir";
      ProgramArguments = [
        "${pkgs.runit}/bin/runsvdir"
        "/Users/${username}/service"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/${username}/Library/Logs/runsvdir.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/runsvdir.log";
    };
  };
}
