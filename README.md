# pisound-prynth
Button scripts for the pisound raspberry pi audio card running on prynth supercollider with setups and scripts

Most of this is ad hoc, experimenting with the prynth system on a rasbperry pi 3. The prynth system currently is based on supercollider 3.9 with a web front end featuring supercolliderjs ... you got. Light weight direct control of sclang with websockets.... 

Find the pisound audio card at https://blokas.io ... buy it. It's a high quality, reliable card. The images for general use (puredata) are augmented by a complete moddep images. It's great! 

You can find the prynth image (I'm using the 2017-09 image) here:
https://prynth.github.io/create/downloads.html

The thing works remarkably well :) What this repo contains:

- a pisound button control script to switch patches being performed by supercollider
- some modified prynth scripts to launch supercollider with pisound appropriate jack settings and start default sc scripts
- some example scripts using sc with the pisound demonstrating midi and audio I/O

The scripts are organized in subfolders as they exist in my context. That is a prynth image for the raspberry pi.


