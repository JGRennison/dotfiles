#!/bin/bash

# Copyright © Jonathan G. Rennison 2016 <j.g.rennison@gmail.com>
# License: New BSD License, see BSD-LICENSE.txt

_git_null_octo_merge ()
{
	__gitcomp_nl "$(__git_refs)"
}
