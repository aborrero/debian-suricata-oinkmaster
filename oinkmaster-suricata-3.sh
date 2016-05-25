#!/bin/sh

# Copyright (c) 2016 Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
# This file is released under the GPLv3 license.
#
# Can obtain a complete copy of the license at: http://www.gnu.org/licenses/gpl-3.0.html
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#
# vars
#

THIS_SCRIPT_NAME=$(basename -- $0)
OINKMASTER_BIN=$(which oinkmaster)
OUTPUT_DIR="/etc/suricata/rules"
CONFIG_FILE=$(mktemp)

CONFIG_CONTENT="
skipfile local.rules
skipfile deleted.rules
skipfile snort.conf
url = https://rules.emergingthreats.net/open/suricata-3.0/emerging.rules.tar.gz
"

#
# functions
#

cleanup()
{
	[ -e $CONFIG_FILE ] && rm -f $CONFIG_FILE
}

msg_info()
{
	echo "INFO: ${THIS_SCRIPT_NAME}: $1"
}

msg_err()
{
	echo "ERROR: ${THIS_SCRIPT_NAME}: $1" >&2
	cleanup
	exit 1
}

#
# main execution
#

# checks
if [ $(id -u) -ne 0 ] ; then
	msg_err "this script requires root permissions"
fi

if [ ! -x $OINKMASTER_BIN ] ; then
	msg_err "no oinkmaster binary found"
fi

if [ ! -w $CONFIG_FILE ] ; then
	msg_err "unable to create config tempfile"
else
	msg_info "config file $CONFIG_FILE"
fi

if [ ! -d $OUTPUT_DIR ] ; then
	msg_err "missing output dir $OUTPUT_DIR"
fi

# generating config and running oinkmaster
echo "$CONFIG_CONTENT" > $CONFIG_FILE
$OINKMASTER_BIN -C $CONFIG_FILE -o $OUTPUT_DIR

cleanup
exit 0
