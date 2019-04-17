IBL-HDRI capture
================

This is a simple bash script to automate the process of capturing HDR
images to make light probes for IBL.

It has been tested in Ubuntu 18.04, with gphoto2 2.5.17 and a Canon EOS 350D,
but should work in any Unix system with gphoto2 installed and a USB connection
to the camera supported by the installed version of gphoto2.

Usage
-----

1. Edit the camera_config file to set the desired parameters for the capture
(ISO, aperture, ...).

2. Connect the camera to USB port and turn it on.

3. Execute capture.sh script and follow on-screen instructions.

