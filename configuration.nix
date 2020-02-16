# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/xcompmgr.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = "option kvm_intel nested=1";
  boot.initrd.kernelModules = [
    "dm-snapshots"
  ];

  virtualisation.libvirtd.enable = true;

  networking.hostName = "mars-nix"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    # consoleKeyMap = "us"; use xkbmap
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim neovim httpie curl termite 
    dasht tmux lf pamix vte-ng firefox xorg.xev
    networkmanagerapplet kvm qemu libvirt virtmanager
    networkmanager networkmanager_dmenu light
    bat docker feh jq xclip zathura xsel
    vscode xorg.xf86videointel xorg.xprop
    autorandr arandr pulsemixer pulsemixer
    pavucontrol xorg.xcompmgr xorg.xdpyinfo
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.fish.enable = true;
  programs.light.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = false;
  services.nixosManual.showManual = true;
  services.upower.enable = true;
  services.xcompmgr.enable = true;
  services.compton = {
    enable = false;
    vSync = false;
    shadow = true;
    inactiveOpacity = "1.0";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.pathsToLink = [ "/libexec" ];
  environment.variables = {
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    BROWSER = "firefox";
    TERMINAL = "termite";
    EDITOR = "nvim";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];

    package = (pkgs.mesa.override {
      galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
      }).drivers;
  };



  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 30;
    config = ''
      Section "InputClass"
        Identifier "touchpad"
        Driver "libinput"
        MatchisTouchpad "on"
        Option "Tapping" "on"
      EndSection

      Section "Device"
      	Identifier "Intel Graphics"
	Driver "intel"
	Option "TearFree" "true"
      EndSection
    '';
    
    layout = "us,se";

    xkbOptions = "eurosign:e,caps:swapescape";
    libinput.enable = true;
    libinput.accelProfile = "flat";

    desktopManager = { default = "none"; xterm.enable = false; };

    displayManager.sddm.enable = true;
    displayManager.sessionCommands = ''
    	${pkgs.xorg.xset}/bin/xset r rate 200 30
    '';

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [ 
        dmenu
        i3blocks-gaps
        i3lock-color
	i3status
      ];
    };
  };
  #
  #
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sebbe = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "kvm" 
      "libvirt" "networkmanager" 
      "systemd-journal" "video" 
      "docker"
    ];
  };
  users.extraUsers.sebbe = {
    shell = "/run/current-system/sw/bin/fish";
  };

  nixpkgs.config.allowUnfree = true;

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
	emojione
	noto-fonts
	noto-fonts-cjk
	noto-fonts-emoji
	fira
	fira-code
	fira-mono
	dejavu_fonts
	emacs-all-the-icons-fonts
	font-awesome-ttf
	hasklig
	powerline-fonts
	material-icons
	iosevka
	hack-font
	freefont_ttf
	corefonts
	inconsolata
	ubuntu_font_family
	ttf_bitstream_vera
    ];
  };
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
