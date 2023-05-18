#!/bin/sh

res=$(printf "100\n90\n80\n70\n60\n50\n" | dmenu)
export BRIGHTNES_CURVE=$(echo "scale=2; $res / 100.0" | bc)

dml picom
