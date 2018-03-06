m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.5, \exp].asSpec;
t = [0.01, 0.5, \exp].asSpec;
p = [1/2, 3, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;
l = [0.1, 0.3, \lin].asSpec;
f = [0.2, 1.2, \lin].asSpec;
// Rumush
// YouTube: https://www.youtube.com/channel/UCs_Cn1R4iFrYOyc8liFucSQ
// Facebook: https://www.facebook.com/rumushproduction
// SoundCloud: https://soundcloud.com/rumushproduction
// Blog: https://mycelialcordsblog.wordpress.com/


SynthDef(\chaosGlitch2, {
	arg len = 10, fundFreq = 40, henA = 2, henB = 0.4, t = 1, gate = 1;
	var mainEnv = EnvGen.kr(Env.triangle(len,1), gate, doneAction:2);
	var speed = Array.geom(4, t, [1.75, 1.25].choose);
	var freq = Array.geom(8, fundFreq*2, 1.5);
	var pulse = {|rat1,rat2|LFPulse.ar(rat1, [0,0.5,1].choose)*LFPulse.ar(rat2)};
	var a = Lag.ar(HenonN.ar(
		speed.choose*(mainEnv*10000.rand),
		henA, henB,
	), 0.01);
	var bass = SinOsc.ar(fundFreq!2*(a*1.0.rand), 0, Lag.ar(pulse.(t, speed.choose), 0.001));
	var tone1 = SinOsc.ar([(fundFreq+Rand(0,5))*a,(fundFreq+Rand(0,5))*a], 0, 0.01*pulse.(speed.choose, speed.choose));
	var tone2 = Pan2.ar(SinOsc.ar(freq.choose*a, 0, 0.1*pulse.(speed.choose, t)), a);
	var tone3 = SinOsc.ar([freq.choose,freq.choose*a], 0, 0.05*pulse.(speed.choose, t))*mainEnv.round(0.25);
	var noise = Pan2.ar(PinkNoise.ar(a*0.1*pulse.(t,t)), a);
	var impulse = RLPF.ar(Impulse.ar(pulse.(t, speed.choose), a), freq.choose+(a*10), 0.01, 0.1).tanh;

	Out.ar(0, (bass+tone1+tone2+tone3+noise+impulse).tanh);
	}
).store;



Pbind(
	\instrument, \chaosGlitch2,
	\dur, 10,
	\len, Pseq([1, 1.5, 1.75, 2]+10,inf),
	\henA, Pseq([2, 1.3, 1.29, 1.25], inf),
	\henB, Pseq([0.2, 0.3], inf),
	\t, Pseq([2, 4, 2, 6], inf),
	\fundFreq, Pseq([40, 600, 8000, 200, 600, 6000], inf),
).play
