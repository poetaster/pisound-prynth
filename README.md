# pisound-prynth

Button scripts for the pisound raspberry pi audio card running on prynth supercollider with setups and scripts

PLEASE NOTE, prynthhas a much more recent (2019) release and I've not yet been able to test everything. The image I note below is still available, but the new version offers a good deal more, especially if you are interested in the prynth hardware. If not and primarilly in pisound + super collider, you're good with this approach, you now. I'm working on it :)

# Introduction

Most of this is ad hoc, experimenting with the prynth system on a rasbperry pi 3 with a pisound audio card. The prynth system currently is based on supercollider 3.9 with a web front end featuring supercolliderjs ... you got. Light weight direct control of sclang with websockets.... 

Find the pisound audio card at https://blokas.io ... buy it. It's a high quality, reliable card. The images for general use (puredata) are augmented by a complete moddep images. It's great! 

You can find the prynth image (I'm using the 2017-09 image) here:
https://prynth.github.io/create/downloads.html

Please note, this is usable, very much so, but a new image is due in the next month which addresses a bunch of issues. Most of those issues are of no concern to me:)

# Contents
The thing works remarkably well :) What this repo contains:

- a pisound button control script to switch patches being performed by supercollider
- some modified prynth scripts to launch supercollider with pisound appropriate jack settings and start default sc scripts
- some example scripts using sc with the pisound demonstrating midi and audio I/O

The scripts are organized in subfolders as they exist in my context. That is a prynth image for the raspberry pi.

# Installation notes:

  *  to get to the pi in the first place, setup wifi. ie. edit /etc/wpa_supplicant/wpa_supplicant.conf before booting the machine. the prynth beta had some setup bugs.
  *  next go through the usual steps of installing pisound as blokaslabs documents.
  *  install the clicks.sh script from this repo
  *  install the supercollider node_js app.js from this repo. You can use the unmodified app, too. I just turn of serial<->osc stuff and tweak jack.
  *  install the supercollider scripts from this repo in /home/pi/prynth/server/public/supercolliderfiles/ 
  *  now clicks load 1.scd, 2.scd, etc. default.scd is, well, default. default.scd loads 1.scd.
  *  install some quarks I use the examples: CCIn (for midi) and Feedback. use Quark.install('Name'). I actually put the quarks in the /root/.local/share/SuperCollider/quarks. This is not good. But, the beta of prynth is running the node app as root. sigh. 

# Notes on the sc scripts.

  *  1.scd is a feedback pitchshift hack. basically, the input is pitchshifted and that shifted audio is used as feedback :) midi cc is used to control the pitchshifter and feedback. 
  *  2.scd is a stutter effect, controlled by midi cc. Audio input is stuttered.
  *  3.scd is a simple 1 line synth cribbed from twitter :)
  *  4.scd is a manic harmonizer with reverb. also controlled by midi cc.

