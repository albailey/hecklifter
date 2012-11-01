hecklifter
==========

NES side scrolling platform engine written mostly in CC65


Porting this to a GIT environment is still a work in progress.   Previously all the tools were running in cygwin.
I will update this README as I get things working in a GIT world.

Getting started
================
The following tools are required:
 - CC65   download from: http://www.cc65.org/
 - ANT    download and follow instructions from http://ant.apache.org/manual/install.html
   -   You will likely want to put 'ant' in your PATH
 - A NES emulator.   I suggest Nintendulator  http://www.qmtpro.com/~nes/nintendulator/

Preparing to Build
================
 - You need to clone or fork (or whatever)  the git repository
 - Copy the sample.dev.properties file to be dev.properties
 - Update the dev.properties file with the paths to the emulator and CC65.
    -  CC65_PATH will be a root directory (before the bin directory)
    -  EMULATOR will be an entire path including the exe.

Building
=========
 - ant all
 - This assumes ant is setup properly in your PATH 

Known Problems
==============
This is still an early development port of working ASM code which is being rewritten in CC65 compatably C code.  
It's far from being usable.
- Scrolling and status area flickering when running in Nintendulator (which means it will likely have the same problems on real hardware)
- Several grey lines at the top.  Those are added to indicate timing.  I need to add build settings to turn them off.

TO DO
======
- move the contents of the TODO file here.
