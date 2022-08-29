#!/bin/bash
find ./* -maxdepth 0  -type d | xargs -n1 basename | xargs stow "${@}"
