(
~shift_register = {arg length = 5, trig, in;

	var buf = LocalBuf(length);
	var count = PulseCount.kr(trig);

	Demand.kr(trig, 0, Dbufwr(in, buf, count));
	Demand.kr(trig, 0, Dbufrd(buf, count + (1..length))).reverse;
};

Ndef(\n1, {

	var amp = 0.1;
	var pulse = Impulse.kr(1/16);
	var rate = TChoose.kr(pulse, [3,5,10]);
	var trans = TChoose.kr(pulse, [0,2,-2,7,-5]);

	//var trig = Impulse.kr([3,5]/2);
	var trig = Trig1.kr(CuspL.ar(rate * 3), 0.001);
	var octave = Demand.kr(PulseDivider.kr(trig, 4), 0, Drand([12,-12], inf));
	var note = Demand.kr(trig, 0, Dseq([42,46,51,54,59,63,66].scramble + trans, inf) + octave);
	var chord = ~shift_register.(5, trig, note);

	var sig = PMOsc.ar(
		Vibrato.ar(K2A.ar(chord.midicps)),
		chord.midicps * LFPulse.kr(1/8).range(1.01, 2.01),
		Env([3,3,0],[0, 0.2], -4).kr(gate:trig)
	);
	sig = sig * AmpCompA.kr(chord.midicps) * amp;

	sig = sig.flatten.sum;
	sig = XFade2.ar(sig!2, GVerb.ar(BPF.ar(sig, 90.midicps), roomsize:50, revtime:8, drylevel:0), 0.2);
	sig;

}).play(fadeTime:4);
)