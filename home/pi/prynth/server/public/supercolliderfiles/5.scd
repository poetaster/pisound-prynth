m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.5, \exp].asSpec;
t = [0.01, 0.5, \exp].asSpec;
p = [1/2, 3, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;
l = [0.1, 0.3, \lin].asSpec;
f = [0.2, 1.2, \lin].asSpec;

SynthDef(\dubecho,{|in, out, length = 1, fb = 0.8, sep = 0.012|
	var input = In.ar(in, 2);
	var feedback = LocalIn.ar(2);
	var output = LeakDC.ar(feedback*fb + input);
	output = HPF.ar(output, 400);
	output = LPF.ar(output, 5000);
	output = output.tanh;
	LocalOut.ar(DelayC.ar(output, 1, LFNoise2.ar(12).range([length,length+sep],[length+sep,length])).reverse);
	ReplaceOut.ar(out, output);
}).add;

// Example as effecet bus
~bus = Bus.audio(s, 2);
~echo = Synth(\dubecho, [\in, ~bus, \length, TempoClock.default.tempo*(3/8), \fb, 0.7, \sep, 0.0012], addAction: \addToTail);

// send something
play{ Out.ar(~bus, SoundIn.ar([0,1])) }

// turn it off
//~echo.free;