{ config, pkgs, ... }: {
	# programs.virt-manager.enable = true;
	
	# users.groups.libvirtd.members = ["spaubleit"];

	# virtualisation.libvirtd.enable = true;
	# virtualisation.spiceUSBRedirection.enable = true;
	
	# home.dconf.settings = {
	# 	"org/virt-manager/virt-manager/connections" = {
	# 			autoconnect = ["qemu:///system"];
	# 			uris = ["qemu:///system"];
	# 	};
	# };

  programs.dconf.enable = true;
  
  users.users.gcis.extraGroups = [ "libvirtd" ];
  
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice 
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    gnome.adwaita-icon-theme
  ];
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}