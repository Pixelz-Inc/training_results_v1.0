#!/bin/bash

# Installs object_detection module

rm -Rf build/
python setup.py clean build -j 32 develop --user

