#!/bin/sh

# pisound-btn daemon for the pisound button.
# Copyright (C) 2016  Vilniaus Blokas UAB, http://blokas.io/pisound
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

CUR_DIR=$(dirname $(readlink -f $0))

. $CUR_DIR/../common/common.sh

log "pisound button clicked $1 times!"

log "Loading `expr $1 - 1`"
# following is the original
#python $CUR_DIR/modep-ctrl.py index `expr $1 - 1`

# now to control supercolliderjs under prynth

FREE="$(curl -s http://localhost:3000/interpret -d 'code=s.freeAll;')"
START="$(curl -s http://localhost:3000/interpret --data-urlencode  code@/home/pi/prynth/server/public/supercolliderfiles/${1}.scd)"
log $START
#if [ $? -eq "OK" ]; then
if [ $START = "OK" ]; then
	for i in $(seq 1 $1); do
		flash_leds 1
		sleep 0.3
	done
else
	flash_leds 50
fi

