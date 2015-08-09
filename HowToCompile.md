# Introduction #

Following the instructions to compile the project

## Windows ##
  * Download and install **Eclipse IDE for C/C++ Developers** from http://www.eclipse.org/downloads/

  * Download and install **MinGW** from http://www.mingw.org/
    1. Download the Automated MinGW Installer
    1. Follow the instructions at http://www.mingw.org/wiki/InstallationHOWTOforMinGW

  * Download and install **OpenCV2.2** from http://opencv.willowgarage.com/wiki/Welcome
    1. Download OpenCV-2.2.0-win.zip
    1. Follow the instuctions at http://opencv.willowgarage.com/wiki/MinGW#OpenCV2.2

  * Configure Eclipse for using MinGW as compiler

  * Create new project

  * Link Includes/Libraries

  * Compile!

## Linux / MacOSX ##
  * Download and install **Eclipse IDE for C/C++ Developers** (make sure to have gcc and g++!)

  * Make sure to have **CMake** and meet the following dependancies:
    * `ffmpeg`
    * `libxine-ffmpeg`
    * `libavcodec-dev`
    * `pgk-config`
    * `libgtk2.0-dev`
> You can them via `apt-get`

  * Download and install **OpenCV2.2** from http://opencv.willowgarage.com/wiki/Welcome, following the instructions at http://opencv.willowgarage.com/wiki/InstallGuide

  * Import the project

  * Link OpenCV's includes and libraries `opencv_core`, `opencv_highgui`, `opencv_video`, `opencv_imgproc`

  * Compile!

# Matlab #
For the matlab part of the code just add the path of the m-files and make sure the path of the c++ executable `iaasfog` is correct (variable exec\_path)