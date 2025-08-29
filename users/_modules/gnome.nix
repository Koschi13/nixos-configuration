{pkgs, ...}: let
  imageViewer = "org.gnome.eog.desktop";
in {
  # GNOME related packages
  home.packages = with pkgs; [
    eog
    gnome-tweaks
    nautilus
    networkmanagerapplet
    pinentry-gnome3
    seahorse
  ];

  xdg.mimeApps.defaultApplications = {
    "png" = imageViewer;
    "jpg" = imageViewer;
    "image/bmp" = imageViewer;
    "image/gif" = imageViewer;
    "image/jpeg" = imageViewer;
    "image/jpg" = imageViewer;
    "image/jxl" = imageViewer;
    "image/pjpeg" = imageViewer;
    "image/png" = imageViewer;
    "image/tiff" = imageViewer;
    "image/webp" = imageViewer;
    "image/x-bmp" = imageViewer;
    "image/x-gray" = imageViewer;
    "image/x-icb" = imageViewer;
    "image/x-ico" = imageViewer;
    "image/x-png" = imageViewer;
    "image/x-portable-anymap" = imageViewer;
    "image/x-portable-bitmap" = imageViewer;
    "image/x-portable-graymap" = imageViewer;
    "image/x-portable-pixmap" = imageViewer;
    "image/x-xbitmap" = imageViewer;
    "image/x-xpixmap" = imageViewer;
    "image/x-pcx" = imageViewer;
    "image/svg+xml" = imageViewer;
    "image/svg+xml-compressed" = imageViewer;
    "image/vnd.wap.wbmp" = imageViewer;
    "image/x-icns" = imageViewer;
  };

  home.file = {
    ".local/share/applications/org.gnome.eog.desktop".source = "${pkgs.eog}/share/applications/org.gnome.eog.desktop";
  };
}
