#!/bin/bash
#

function kill_process {
  if [ "`ps -axuw | grep $1 | grep -v grep`" ]; then
    killall $1 2> /dev/null
  fi
}

function check_result {
  if [ $? != 0 ]; then
    echo "ERROR: $1"
    exit 3
  fi
}

function set_config {
  gphoto2 --set-config $1=$2
  check_result "Cannot set config $1=$2"
}

function get_config {
  gphoto2 --get-config $1 | grep ^Current: | cut -f2 -d' '
}

function manual_step {
  echo $1
  read LINE
}

# Kill processes potentially locking the camera
kill_process gvfs-gphoto2-volume-monitor
kill_process gvfsd-gphoto2

# Check camera connection
gphoto2 --summary
check_result "Camera not detected"

gphoto2 --get-config iso > /dev/null
if [ $? != 0 ]; then
  echo "Cannot access camera. Check that 'Communication mode' is set as 'PC Connection' and try again"
  exit 1
fi

manual_step "Disable lens stabilizer and press any key"
manual_step "Set the white balance (WB) to an adequate fixed value. The press any key"
manual_step "Frame the ball (fill as much frame as you can, but don't crop). Then press any key"

# Camera focus
manual_step "Focus the image. Then press any key"
set_config focusmode 3	# Manual focus

# Read camera configuration file
source camera_config

# Check shooting mode

CURRENT_SHOOTING_MODE=`get_config shootingmode`
if [ $CURRENT_SHOOTING_MODE != "M" ]; then
  manual_step "Set shooting mode to manual (M) and press any key"
  CURRENT_SHOOTING_MODE=`get_config shootingmode`
  if [ $CURRENT_SHOOTING_MODE != "M" ]; then
    echo "Current shooting mode is $CURRENT_SHOOTING_MODE. Please turn the wheel to manual (M) mode and try again"
    exit 2
  fi
fi

# Set camera configuration

set_config iso $ISO
set_config imageformat $IMAGEFORMAT

#set_config meteringmode $METERING_MODE

set_config aperture $APERTURE

# Center exposure

manual_step "Set shutter speed for the center exposure and press any key"

CENTER_EXPOSURE=`get_config shutterspeed`
#echo $CENTER_EXPOSURE

CENTER_SHUTTERSPEED_INDEX=`gphoto2 --get-config shutterspeed |grep "Choice" | grep $CENTER_EXPOSURE\$ | cut -f2 -d' '`
echo "Center shutter speed index: $CENTER_SHUTTERSPEED_INDEX"

# Center exposure
gphoto2 --capture-image-and-download

# Additional steps
for s in $STEPS ; do
  SHUTTERSPEED_IDX=`expr $CENTER_SHUTTERSPEED_INDEX + $s`
  echo "Shooting with shutterspeed idx: $SHUTTERSPEED_IDX"
  gphoto2 --set-config shutterspeed=$SHUTTERSPEED_IDX
  if [ $? == 0 ]; then
    gphoto2 --capture-image-and-download
  else
    echo "Shutter speed idx $SHUTTERSPEED_IDX is out of bounds"
  fi
done

echo "Capture finished!"
