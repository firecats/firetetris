# firetetris
This is the frontend for [Fire Tetris](http://firetetris.com/)

We follow [GitHub flow](https://guides.github.com/introduction/flow/) for this project.  In other words, for any changes, please make them on a branch, open a Pull Request, and let the team discuss them.

To avoid duplication, let people know what you're working on.  [Slack #firetetris](https://firetetris.slack.com/messages/software/) is probably the best way to do this but you can also feel free to create GitHub issues.

---

# Project Overview

## What we want:

We want to support two modes of play: something like NES / Gameboy Tetris, since that's what most participants will be familiar with, and something like Tetris Grand Master, because there will be some people out there who can play at that level and we all want to see that!
https://www.youtube.com/watch?v=eQOswiAGLU4

We want to support classic NES controllers (via a USB adaptor) for solo play, plus 4 player mode with 4 independent buttons: left, right, drop, rotate.

## Basic software stack:

* **Firmware:** Arduino C/C++ for the dmxfire16 board.  The Super Street Fire firmware is almost exactly what we need here - just needs to be expanded to 25 channels.  Jody will get a version of this firmware that automatically shuts off solenoids after a delay (from Seth Hardy, the board's creator) - there is very little left to do beyond that.

* **Backend:** a small server written in golang that receives UDP packets containing the desired screen state and sends control signals to the dmxfire16 boards.  This is useful so we can swap in different frontends later, and so we can test + debug without having dmxfire16 boards present.

* **Frontend:** we will write this in processing, based on: http://www.openprocessing.org/sketch/34481

Note that processing can run JavaScript code now, so if it's useful we can plug that in.
