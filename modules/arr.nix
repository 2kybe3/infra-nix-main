{config, ...}: let
  inherit
    (config.kybe.lib)
    domain
    ;
  inherit
    (config.kybe.lib.caddy)
    createCaddyProxy
    ;
in {
  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /media 0775 root media -"
    "d /media/sonarr 0775 root media -"
    "d /media/radarr 0775 root media -"
  ];

  services = {
    jellyfin = {
      enable = true;
      group = "media";
    };

    sonarr = {
      enable = true;
      group = "media";
    };
    radarr = {
      enable = true;
      group = "media";
    };
    prowlarr.enable = true;

    flaresolverr.enable = true;
    jackett = {
      enable = true;
      group = "media";
    };

    caddy.virtualHosts = {
      "jellyfin.${domain}" = createCaddyProxy 8096;

      "sonarr.${domain}" = createCaddyProxy 8989;
      "radarr.${domain}" = createCaddyProxy 7878;
      "prowlarr.${domain}" = createCaddyProxy 9696;

      "jackett.${domain}" = createCaddyProxy 9117;

      "flaresolverr.${domain}" = createCaddyProxy 8191;
    };
  };
}
