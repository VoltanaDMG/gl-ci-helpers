#!/bin/sh
set -x
sudo apt install libglu1-mesa-dev freeglut3-dev mesa-common-dev -y
# Add glfw3 version 3.2.1
version="3.2.1" && \
wget "https://github.com/glfw/glfw/releases/download/${version}/glfw-${version}.zip" && \
unzip glfw-${version}.zip && \
cd glfw-${version} && \
sudo apt-get install cmake xorg-dev libglu1-mesa-dev && \
sudo cmake -G "Unix Makefiles" && \
sudo make && \
sudo make install && \
cd .. && \
sudo rm -rf glfw-${version}
set +x
