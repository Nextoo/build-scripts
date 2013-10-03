#!/bin/bash
# Name: update_tree_world.sh
# Purpose: update the portage tree, showing what the differences are, then update world. 

# Author: Dayton
# Date last modified: 2013.10.03


eix-sync
emerge -DvNut world