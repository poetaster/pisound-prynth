(
~stutter = { |snd, reset, fragmentlength, rate = 1.0, maxdelay = 10|
    var phase, fragment, del;
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
	DelayC.ar(snd, maxdelay , del);
};
)
(
SynthDef(\stuttertest, { |out = 0, buf, t_reset = 0, fragmentlength = 0.1, amp = 0.1|
    var snd, reset;
	snd = SoundIn.ar([0,1.0]);
	reset = Onsets.kr(FFT(LocalBuf(512), snd), t_reset);
    snd = ~stutter.(snd, reset, fragmentlength);
    Out.ar(out, snd * amp!2);
}).add;
)
(
Pmono(\stuttertest,
    \buf, b,
    \amp, 0.5,
    \reset, 0.7,
    \dur, 0.5,
    \fragmentlength, Pseq([0.09, 0.15, 0.17, 0.12, 0.1], inf)
).play;
)

