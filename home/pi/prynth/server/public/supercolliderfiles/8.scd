// allocate a Buffer
s = Server.local;
b = Buffer.alloc(s, 48000 * 1.0, 1); // a four second 1 channel Buffer


SynthDef("granular_sampling", {arg trigger = 0, graindur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1, gate = 1;
	var env, snd;
	RecordBuf.ar(SoundIn.ar(0), sndbuf, loop: 1);
	env = EnvGen.kr(Env.asr, gate, levelScale: amp, doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 1,
		trigger: Impulse.kr(trigger),
		dur: graindur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
			
	//snd = DelayC.ar(snd, 0.5, 0.4);
	snd = XFade2.ar(snd!2, GVerb.ar(BPF.ar(snd, 90.midicps), roomsize:30, revtime:8, drylevel:0), 0.2);
	//snd = GVerb.ar(BPF.ar(snd, 90.midicps), roomsize:30, revtime:8, drylevel:1.0);
			
	//snd = snd + (SoundIn.ar([0,1]) * 0.3);
	snd = snd!2 * 0.5;
	Out.ar(0, [ (SoundIn.ar([0,1]) * 0.1), (snd * env ) ] ); // original
			// this is a freak :) but get's env and stereo ;)
	//Out.ar(0, (snd!2  * 1.5) *env + (SoundIn.ar([0,1]) * 0.1) );
	// this one is just mono		Out.ar(0, (snd * env) + SoundIn.ar(0,1));
}).add;

a = Pbind(
	\instrument, "granular_sampling",
	\trigger, 12,
	\graindur, Prand([0.09,0.01,0.05], inf), //Pseq([0.125, 0.225, 0.325, 0.425, 0.525, 0.425, 0.325], inf),
	\sndbuf, b,
	\transp, Prand([2/3,1+1/3,1+2/3], inf),
	\pos, 0,
	//\pos, Pseq([1/4,1/2,3/4], inf),
	\pan, 0,
	\amp, Prand([0.6, 0.7], inf),
	\envbuf, -1,
	\dur, Prand([2/3,3/4,1], inf)
);

a.play;
