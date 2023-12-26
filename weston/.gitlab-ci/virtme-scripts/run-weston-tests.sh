#!/bin/bash

# folders that are necessary to run Weston tests
mkdir -p /tmp/tests
mkdir -p /tmp/.X11-unix
chmod -R 0700 /tmp

# set environment variables to run Weston tests
export XDG_RUNTIME_DIR=/tmp/tests
export WESTON_TEST_SUITE_DRM_DEVICE=card0
export LIBSEAT_BACKEND=seatd

# ninja test depends on meson, and meson itself looks for its modules on folder
# $HOME/.local/lib/pythonX.Y/site-packages (the Python version may differ).
# build-deps.sh installs dependencies to /usr/local.
# virtme starts with HOME=/tmp/roothome, but as we installed meson on user root,
# meson can not find its modules. So we change the HOME env var to fix that.
export HOME=/root
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/bin:$PATH

export ASAN_OPTIONS=detect_leaks=0,atexit=1
export SEATD_LOGLEVEL=debug

# run the tests and save the exit status
# we give ourselves a very generous timeout multiplier due to ASan overhead
echo 0x1f > /sys/module/drm/parameters/debug
seatd-launch -- meson test --no-rebuild --timeout-multiplier 4
# note that we need to store the return value from the tests in order to
# determine if the test suite ran successfully or not.
TEST_RES=$?
dmesg &> dmesg.log
echo 0x00 > /sys/module/drm/parameters/debug

# create a file to keep the result of this script:
#   - 0 means the script succeeded
#   - 1 means the tests failed, so the job itself should fail
TESTS_RES_PATH=$(pwd)/tests-res.txt
echo $TEST_RES > $TESTS_RES_PATH

# shutdown virtme
sync
poweroff -f
