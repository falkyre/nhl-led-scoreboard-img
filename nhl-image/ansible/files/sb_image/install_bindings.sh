#!/bin/bash
cd /home/pi/nhl-led-scoreboard

#Install rgb matrix
# Pull submodule and ignore changes from script
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

make build-python PYTHON=/home/pi/nhlsb-venv/bin/python3.9
make install-python PYTHON=/home/pi/nhlsb-venv/bin/python3.9

mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori
mv /home/pi/sbtools/runtext.py bindings/python/samples/