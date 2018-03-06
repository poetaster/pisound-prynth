m = CCIn();
q = [30, 60, \lin].asSpec;
g = [60, 90, \lin].asSpec;
t = [0.001, 0.2, \exp].asSpec; // pitch dispersion time
p = [0.001, 0.2, \exp].asSpec; // pitch dispersion
f = [0.5, 2.0, \exp].asSpec; // frequency multiple for harmonizer
r = [1, 5, \lin].asSpec; // rev room size
n = [1, 10, \lin].asSpec; // rev time

// define the Synth itself:
// - first it determines the pitch of what it hears in the microphone
// - then it harmonizes the pitch with the notes as defined in the ui

SynthDef.new("pitchFollow1",{
    var in, amp, freq, hasFreq, out;
	var t, midinum;
	var harmony, harmony2, partials;
    in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 1);
    # freq, hasFreq = Tartini.kr(in, ampThreshold: 0.02, median: 7);
	midinum = freq.cpsmidi.round(1);
	//midinum.postln;
    //freq = Lag.kr(midinum.midicps, 0.01);
	//freq = midinum.midicps;
	harmony2= midinum - 3 / 127;
	//harmony2 = m.kr(0,0,q);
	//harmony2 = midi
	harmony = midinum - 5 / 127;
	//harmony = m.kr(0,1,g);
	partials = [
		   m.kr(0,2,f),
		   m.kr(0,3,f),
		   m.kr(0,4,f),
		   m.kr(0,2,f)*harmony,
		   m.kr(0,3,f)*harmony,
		   m.kr(0,4,f)*harmony,
		   m.kr(0,2,f)*harmony2,
		   m.kr(0,3,f)*harmony2,
		   m.kr(0,4,f)*harmony2,
	];
	out = Mix.new(PitchShift.ar(in, 0.2, partials,  m.kr(0,0,p),  m.kr(0,1,t));
    out = XFade2.ar(out!2, GVerb.ar(BPF.ar(out, 90.midicps), roomsize:40, revtime:m.kr(0,6,n), drylevel:0.5), 0.2);
	
    7.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2);
    });
	

	Out.ar(0,(out/partials.size));

}).play(s);

