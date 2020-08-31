# Manual webcam controls
WEBCAM=/dev/video0
CTL_CMD="v4l2-ctl --device $WEBCAM"

webcam-ctl() {
  if [ -z "$1" ]; then
      $CTL_CMD --list-ctrls-menus
  else
      $CTL_CMD --get-ctrl $1
  fi
}

webcam-ctl-brightness() {
  if [ -z "$1" ]; then
      webcam-ctl brightness
  else
      $CTL_CMD --set-ctrl brightness=$1
  fi
}

webcam-ctl-contrast() {
  if [ -z "$1" ]; then
      webcam-ctl contrast
  else
      $CTL_CMD --set-ctrl contrast=$1
  fi
}

webcam-ctl-saturation() {
  if [ -z "$1" ]; then
      webcam-ctl saturation
  else
      $CTL_CMD --set-ctrl saturation=$1
  fi
}

webcam-ctl-white_balance_temperature_auto() {
  if [ -z "$1" ]; then
      webcam-ctl white_balance_temperature_auto
  else
      $CTL_CMD --set-ctrl white_balance_temperature_auto=$1
  fi
}

webcam-ctl-gain() {
  if [ -z "$1" ]; then
      webcam-ctl gain
  else
      $CTL_CMD --set-ctrl gain=$1
  fi
}

webcam-ctl-power_line_frequency() {
  if [ -z "$1" ]; then
      webcam-ctl power_line_frequency
  else
      $CTL_CMD --set-ctrl power_line_frequency=$1
  fi
}

webcam-ctl-white_balance_temperature() {
  if [ -z "$1" ]; then
      webcam-ctl white_balance_temperature
  else
      $CTL_CMD --set-ctrl white_balance_temperature=$1
  fi
}

webcam-ctl-sharpness() {
  if [ -z "$1" ]; then
      webcam-ctl sharpness
  else
      $CTL_CMD --set-ctrl sharpness=$1
  fi
}

webcam-ctl-backlight_compensation() {
  if [ -z "$1" ]; then
      webcam-ctl backlight_compensation
  else
      $CTL_CMD --set-ctrl backlight_compensation=$1
  fi
}

webcam-ctl-exposure_auto() {
  if [ -z "$1" ]; then
      webcam-ctl exposure_auto
  else
      $CTL_CMD --set-ctrl exposure_auto=$1
  fi
}

webcam-ctl-exposure_absolute() {
  if [ -z "$1" ]; then
      webcam-ctl exposure_absolute
  else
      $CTL_CMD --set-ctrl exposure_absolute=$1
  fi
}

webcam-ctl-exposure_auto_priority() {
  if [ -z "$1" ]; then
      webcam-ctl exposure_auto_priority
  else
      $CTL_CMD --set-ctrl exposure_auto_priority=$1
  fi
}

webcam-ctl-pan_absolute() {
  if [ -z "$1" ]; then
      webcam-ctl pan_absolute
  else
      $CTL_CMD --set-ctrl pan_absolute=$1
  fi
}

webcam-ctl-tilt_absolute() {
  if [ -z "$1" ]; then
      webcam-ctl tilt_absolute
  else
      $CTL_CMD --set-ctrl tilt_absolute=$1
  fi
}

webcam-ctl-focus_absolute() {
  if [ -z "$1" ]; then
      webcam-ctl focus_absolute
  else
      $CTL_CMD --set-ctrl focus_absolute=$1
  fi
}

webcam-ctl-focus_auto() {
  if [ -z "$1" ]; then
      webcam-ctl focus_auto
  else
      $CTL_CMD --set-ctrl focus_auto=$1
  fi
}

webcam-ctl-zoom_absolute() {
  if [ -z "$1" ]; then
      webcam-ctl zoom_absolute
  else
      $CTL_CMD --set-ctrl zoom_absolute=$1
  fi
}

