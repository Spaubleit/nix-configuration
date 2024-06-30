{ lib, config, ... }: {
  options = {
    people.me = lib.mkOption {
      default = "spaubleit";
      description = "username";
    };
  };

  config = {
    users.users.${config.people.me} = {
      isNormalUser = true;
      initialPassword = "1234";
    };
  };
}
