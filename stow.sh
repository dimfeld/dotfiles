#!/bin/bash
fd -t d -d 1 | xargs stow "${@}"
