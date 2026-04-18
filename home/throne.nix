{
  config,
  lib,
  mylib,
  pkgs,
  system,
  ...
}:
let
  isDarwin = mylib.isDarwin system;
  jq = lib.getExe pkgs.jq;
  homeDir = config.home.homeDirectory;
  throneConfigDir =
    if isDarwin then
      "${homeDir}/Library/Preferences/Throne/config"
    else
      "${homeDir}/.config/Throne/config";

  directCidrs = [
    "10.0.0.0/8"
    "100.64.0.0/10"
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "::1/128"
    "fc00::/7"
    "fe80::/10"
  ];

  directDomainSuffixes = [
    "lan"
    "local"
    "ru"
  ];

  directDomainRegexes = [
    "(^|\\.)gitlab\\..+$"
  ];

  directRuleSets = [
    "geoip-ru"
    "geosite-ru"
    "geosite-ru-available-only-inside"
  ];

  managedDefaultProfile = builtins.toJSON {
    default_outbound = -1;
    id = 0;
    name = "Default";
    rules = [
      {
        actionType = "hijack-dns";
        invert = false;
        ip_is_private = false;
        ip_version = "";
        name = "Route DNS";
        network = "";
        noDrop = false;
        outboundID = -2;
        override_address = "";
        override_port = 0;
        protocol = "dns";
        rejectMethod = "";
        simple_action = 0;
        sniffOverrideDest = false;
        source_ip_is_private = false;
        strategy = "";
        type = 0;
      }
      {
        actionType = "route";
        invert = false;
        ip_cidr = directCidrs;
        ip_is_private = false;
        ip_version = "";
        name = "Bypass LAN and Link-Local";
        network = "";
        noDrop = false;
        outboundID = -2;
        override_address = "";
        override_port = 0;
        protocol = "";
        rejectMethod = "";
        simple_action = 0;
        sniffOverrideDest = false;
        source_ip_is_private = false;
        strategy = "";
        type = 0;
      }
      {
        actionType = "route";
        domain_regex = directDomainRegexes;
        domain_suffix = directDomainSuffixes;
        invert = false;
        ip_is_private = false;
        ip_version = "";
        name = "Bypass Local and RU Domains";
        network = "";
        noDrop = false;
        outboundID = -2;
        override_address = "";
        override_port = 0;
        protocol = "";
        rejectMethod = "";
        simple_action = 0;
        sniffOverrideDest = false;
        source_ip_is_private = false;
        strategy = "";
        type = 0;
      }
      {
        actionType = "route";
        invert = false;
        ip_is_private = false;
        ip_version = "";
        name = "Bypass Russian Services";
        network = "";
        noDrop = false;
        outboundID = -2;
        override_address = "";
        override_port = 0;
        protocol = "";
        rejectMethod = "";
        rule_set = directRuleSets;
        simple_action = 0;
        sniffOverrideDest = false;
        source_ip_is_private = false;
        strategy = "";
        type = 0;
      }
    ];
  };

  managedRouteSettings = builtins.toJSON {
    current_route_id = 0;
  };
in
{
  home.activation.configureThroneRouting = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        throne_config_dir="${throneConfigDir}"
        throne_route_dir="$throne_config_dir/route_profiles"
        throne_profile_path="$throne_route_dir/0.json"
        throne_route_settings_path="$throne_route_dir/Default"
        throne_configs_path="$throne_config_dir/configs.json"

        mkdir -p "$throne_route_dir"

        write_if_changed() {
          local target_path tmp_path

          target_path="$1"
          tmp_path="$2"

          if [ ! -f "$target_path" ] || ! cmp -s "$tmp_path" "$target_path"; then
            mv "$tmp_path" "$target_path"
            echo "Updated Throne routing file: $target_path"
          else
            rm -f "$tmp_path"
          fi
        }

        tmp_profile="$(mktemp)"
        cat > "$tmp_profile" <<'EOF'
    ${managedDefaultProfile}
    EOF
        write_if_changed "$throne_profile_path" "$tmp_profile"

        tmp_route_settings="$(mktemp)"
        if [ -f "$throne_route_settings_path" ]; then
          ${jq} '.current_route_id = 0' "$throne_route_settings_path" > "$tmp_route_settings"
        else
          cat > "$tmp_route_settings" <<'EOF'
    ${managedRouteSettings}
    EOF
        fi
        write_if_changed "$throne_route_settings_path" "$tmp_route_settings"

        if [ -f "$throne_configs_path" ]; then
          tmp_configs="$(mktemp)"
          ${jq} '.active_routing = "Default"' "$throne_configs_path" > "$tmp_configs"
          write_if_changed "$throne_configs_path" "$tmp_configs"
        fi
  '';
}
