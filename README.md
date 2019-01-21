# ESU-bridge-web-server
Embedded web server for the Protothrottle ESU Bridge interface
PTlauncher User’s Guide

The PTlauncher program supports the Iowa Scaled Engineering Protothrottle ESU-Bridge interface processes by providing a web based console interface that allows for simpler debugging of the operation and configuration of the Protothrottle bridge software.

The PT Bridge software supports many different manufacturers interfaces and configuration and debugging of those interfaces can be difficult when things don’t go right.  By default the PT Bridge software writes messages to the console after the Raspberry PI boots and executes the primary Python script that implements the interface.  These messages are not visible unless one attaches an HDMI display to the inteface which is not always possible or convenient.  The PTlauncher solves this by providing a web browser display of those console messages as well as allowing the editing of the configuration file that drives the bridge software and the ability to restart the interface software without  needing to do a hard reboot of the interface device.

The PTlauncher is implemented with one program (an executable) and two Linux shell scripts that execute the program and that the PTlauncher uses to run the actual PT Bridge software.  The files are:

pi-start-esubridge.sh -  This is the replacement for the existing shell script that starts the whole process off when the PT bridge hardware is powered on.  This has been modified to set the raspberry PI clock using ntpdate and then execute PTlauncher.

run_bridge.sh            -  This shell script is started by PTlauncher when it is first invoked.  It executes the Python script esu-bridge.py which is the main interface script for the actual PT Bridge application.  It copies the existing protothrottle-config.txt file to temporary read/write storage so it can be modified while the PTlauncher is running.  These modifications are temporary because in normal operation the PT Bridge operates with read only file structures on the Raspberry PI memory card.
PTlauncher               -  This is the embedded web server which runs on port 8015 by default.  The web server executes run_bridge.sh on startup and whenever the “Restart” link on the   primary web page is clicked.  Prior to restarting the bridge software any previous executing software is stopped.  On can override the default web server port using the “- port <port number>” argument on the PTlauncher command line.  The PTlauncher main display is the output from the python script that implements the PT bridge functions.  The output window is shown in realtime with a reverse order (newest first) listing from sysout.  Each displayed line is time tagged with the current date and time.

PTlauncher is a Tool Command Language (TCL) Starpack containing in a self-extracting zip file a TCL  interpreter (version 8.6) a standard TCLHttpd web server (Version 3.5.1) and custom code that implements the display.  The web interface should be compatible with all web browsers that exist in the last 10 years or so.

The above 3 files should be placed in the /home/iascaled/esu-bridge directory with execute privileges set for all 3 files. 

The web browser url would look like:
http://<IP address>:8015 using the default port.


