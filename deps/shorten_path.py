#!/usr/bin/env python
import sys

# This script is from http://stackoverflow.com/a/1616781
# Author: John Kugelman
# License: cc by-sa 3.0 (as per Stack Exchange user contributions)
#	http://creativecommons.org/licenses/by-sa/3.0/
# This comment block added by: Jonathan G. Rennison <j.g.rennison@gmail.com>

try:
	path   = sys.argv[1]
	length = int(sys.argv[2])

	if len(sys.argv) > 3:
		shrtstr = sys.argv[3].decode('utf-8')
	else:
		shrtstr = ".."

	shrtstrlen = len(shrtstr)

except:
	print >>sys.stderr, "Usage: $0 <path> <length> [<shorten-string>]"
	sys.exit(1)

while len(path) > length:
	dirs = path.split("/");

	# Find the longest directory in the path.
	max_index  = -1
	max_length = shrtstrlen + 1

	for i in range(len(dirs) - 1):
		if len(dirs[i]) > max_length:
			max_index  = i
			max_length = len(dirs[i])

	# Shorten it by one character.
	if max_index >= 0:
		dirs[max_index] = dirs[max_index][:max_length-(shrtstrlen + 1)] + shrtstr
		path = "/".join(dirs)

	# Didn't find anything to shorten. This is as good as it gets.
	else:
		break

print path.encode('utf-8')
