m = CCIn();
q = [30, 60, \lin].asSpec;
g = [60, 90, \lin].asSpec;
t = [0.01, 1.0, \exp].asSpec;
p = [1/2, 2.0, \exp].asSpec;


// define the Synth itself:
// - first it determines the pitch of what it hears in the microphone
// - then it harmonizes the pitch with the notes as defined in the ui

SynthDef.new("pitchFollow1",{
    var in, amp, freq, hasFreq, out;
	var t, midinum;
	var harmony, harmony2, partials;
    in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 1);
    # freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	midinum = freq.cpsmidi.round(1);
	//midinum.postln;
    //freq = Lag.kr(midinum.midicps, 0.01);
	//freq = midinum.midicps;
	harmony2= midinum+3;
	//harmony2 = m.kr(0,0,q);
	//harmony2 = midi
	harmony = midinum+5;
	//harmony = m.kr(0,1,g);
	partials = [
		   0.5,
		   1,
		   2,
		 0.50*harmony,
		   1*harmony,
		   2*harmony,
		 0.5*harmony2,
		   1*harmony2,
		   2*harmony2,
	];
	out = Mix.new(PitchShift.ar(in, 0.2, partials, 0, 0.001));

    7.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
    });

	Out.ar(0,(out/partials.size))

}).play(s);

