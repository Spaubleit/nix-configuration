_ :
let disks = { 
  main = "/dev/nvme0n1p1"; 
  store = "/dev/nvme1n1";
  raid1 = "/dev/sdc";
  raid2 = "/dev/sdd";
};
in {
  disko.devices.disk = {
    main = {
      type = "disk";
      device = disks.main;
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
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
              };
            };
          };
        };
      };
    };
    store = {
      type = "disk";
      device = disks.store;
      content = {
        type = "gpt";
        partitions = {
          store = {
            name = "store";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
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
    raid = {
      type = "disk";
      device = disks.raid1;
      content = {
        type = "gpt";
        partitions = {
          raid = {
            name = "raid";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-m raid1 -d raid1 ${disks.raid1} ${disks.raid2}" ];
              subvolumes = {
                "@data" = {
                  mountpoint = "/mnt/data";
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