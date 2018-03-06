(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\in_grain_test, {arg gate = 1, amp = 1, pan=0, pdis= 0.02, tdis= 0.1, rate = 1.5, delay=0.1, envbuf, attackTime = 0.04, decayTime = 1, sustainLevel = 1, releaseTime = 1.5;
    var env, grains;
    /*env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: 2);*/
	env = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
	grains = GrainIn.ar(2, Impulse.kr(8), 1, SoundIn.ar([0,1]), pan, envbuf, 128);
	grains = DelayC.ar(grains, 1, delay);
	//grains = DelayC.ar(SoundIn.ar([0,1]), 1, delay);
	Out.ar(0, PitchShift.ar(grains, 0.12, rate, pdis, tdis) * env)
    }).send(s);

)

//octave 2:1, fourth 4:3, fifth 3:2, 9:8
// use built-in env
x = Synth(\in_grain_test, [\rate, 1/2, \pdis, 0.02, \delay, 0.1, \pan, -1]);
y = Synth(\in_grain_test, [\rate, 3/4, \pdis, 0.09, \delay, 0.2, \pan, -1]);
z = Synth(\in_grain_test, [\rate, 3/2, \pdis, 0.01, \delay, 0.3, \pan, 1]);
t = Synth(\in_grain_test, [\rate, 9/8, \pdis, 0.05, \delay, 0.4, \pan, 1]);
// switch to the custom env
x.set(\envbuf, z);
x.set(\envbuf, -1);

(
x.set(\gate, 0);
y.set(\gate,0);
z.set(\gate,0);
t.set(\gate,0);
)