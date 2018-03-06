SynthDef("granular_sampling", {arg trigger = 0, graindur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1, gate = 1;
	var env, snd;
	env = EnvGen.kr(Env.asr, gate, levelScale: amp, doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(trigger),
		dur: graindur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
	Out.ar(0, snd * env);
}).add;

var sndbuf = AudioIn.ar([1,2]);

// **************************************
// 3) PLAY IT USING PATTERNS (Pbind)
// **************************************


a = Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 1,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
);


/*
Explanation of the parameters:
- TRIGGER: how many grains per second. Zero means just one grain. Texture gets denser with higher numbers.
- GRAINDUR: duration of the grain, in seconds.
- SNDBUF: the buffer where the sound file is loaded.
- TRANSP: transposition rate. 1 = no transp, 2 = octave above, 1/2 = octave below, etc. If you use a negative number, it will be played in REVERSE!
- POS: position (0-1) in the sound file from where to read the grain.
- PAN: placement of the resulting grain between Left and Right speakers (-1 to +1).
- AMP: amplitude of the grain (volume), between 0 and 1.
- ENVBUF: the amplitude envelope of a single grain (-1 gives you a default env).
- DUR: this is where you specify the rhythm of the sequence (values in seconds)
*/


// You can do a lot just by changing those fixed numbers.
// But you can do a lot more if you create PATTERNS with them...


b = Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([0.33, 0.34, 0.26, 0.51], inf),
	\sndbuf, b,
	\transp, Pseq([1, 1, 1, 1, 1, 1, 1, 1.5], inf),
	\pos, Pseq([0.2, 0.11, 0.12, 0.14], inf),
	\pan, Pwhite(-1, 1),
	\amp, Prand([0.9, 1], inf),
	\envbuf, -1,
	\dur, Pseq([0.25, 0.125, 0.125, 0.6], inf);
);


/*

Explanation of pattern expressions:

Pwhite(0, 1) = will pick any number between a low and a high value that you provide (in this case, 0 and 1).

Pseq([1, 2, 5, 3], inf) = will read a list in sequence from left to right. List has to be between [ ].

Prand([1, 2, 5, 3], inf) = will pick a random item FROM THE LIST every time. List has to be between [ ].

You can use a pattern like the above to define any parameter inside the Pbind, as long as you choose sensible values.

*/

// Here's another example:

c = Pbind(
	\instrument, "granular_sampling",
	\trigger, Pwhite(1, 2),
	\graindur, Pseq([0.3, 0.4, 0.6, 1], inf),
	\sndbuf, b,
	\transp, Prand([1, 1, 1, 1, 1], inf),
	\pos, Prand([0, 0.1, 0.2, 0.14, 0.1, 0.1, 0.14], inf),
	\pan, Pseq([-1, -0.5, 0, 0.5, 1], inf),
	\amp, Prand([0.5, 1], inf),
	\envbuf, -1,
	\dur, Pseq([0.15, 0.2], inf);
);


// The default grain envelope is like a "bell shape", smooth attack and decay.
// Try now applying a custom grain envelope, for example a percussive one.

z = Buffer.sendCollection(s, Env.perc.discretize, 1);

// Now in the Pbind you can use "z" for envbuf instead of -1.

// Another example

d = Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([Pseq([0.1], 15), 0.2], inf),
	\sndbuf, b,
	\transp, Pseq([ Pseq([1], 7), Prand([1, 0.9], 1) ], inf),
	\pos, Pseq([0, 0.1, 0.2, 0.5, 0.1, 0.1, 0.32, 0.2322], inf) * Prand([1, 2], inf),
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.8, 1),
	\envbuf, -1,
	\dur, 0.15;
);


// Yet another example

e = Pbind(
	\instrument, "granular_sampling",
	\trigger, 4,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, -24 + Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, -1,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 3,
);


// One more example

f = Pbind(
	\instrument, "granular_sampling",
	\trigger, 5,
	\graindur, Pseq([0.9, 5, 0.9, 5], inf),
	\sndbuf, b,
	\transp, Pseq([0.5, 0.5, 0.5, 0.5], inf),
	\pos, Pseq([0.12, 0.12, 0.12, 0.12], inf),
	\pan, 0,
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1], inf) * 1/2,
);


// Last example

g = Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(0.9, 1.2),
	\pos, Pseq([0.12, 0.12, 0, 0.13, 0.14], inf) + Pwhite(0, 0.01),
	\pan, 0,
	\amp, 1,
	\envbuf, -1,
	\dur, 0.9,
);
//a.play;

a.play;
/*c.play;
d.play;
e.play;
f.play;
g.play;
g.play;
*/


	)
});
)
