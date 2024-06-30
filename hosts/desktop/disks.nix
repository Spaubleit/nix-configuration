_ :
let disks = { sda = "/dev/sda"; }
in {
  disco.devices.disk = {
    sda = {
      type = "disk";
      device = disks.sda;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              mountpoint = "/partition-root";
              # mountOptions = [ "compress=zstd" "noatime" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}