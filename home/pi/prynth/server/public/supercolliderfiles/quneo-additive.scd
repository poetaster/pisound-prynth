// ************************************
// Additive Synthesis Demo with QuNEO
// Patch 1 - Harmonic Series
// based on patch by http://sccode.org/1-4UO Bruno Ruviaro, 2013-07-22
// this version, blueprint@poetaster.de
// ************************************

/*
Use QuNEO SCLOrk Preset #1 for piano-like play

Pads play 16 first partials of the harmonic series:

13 14 15 16
09 10 11 12
05 06 07 08
01 02 03 04

Long Slider controls fundamental frequency
Vertical Sliders control ADSR envelope
Top two horizontal sliders control the frequency and the resonance of a filter.

The pad note and velocity control the usual factors. 
The pad x / y control values controll the frequency and depth of modulation.
The pad pressure controls the add amount of the lfo from x/y and also the resonance of the filter.
*/

s.waitForBoot({

	// Some variables

	var notes = Array.newClear(64);
	var ints = Array.series(16, 36, 1);

	~att = 0.01;
	~dec = 0.3;
	~sus = 0.5;
	~rel = 1.0;
	~lpfFreq = 0.5;
	~lpfRes = 0.5;
	~fundamental = 110;
	~quNeoChannel = 0;

	MIDIIn.connectAll;

	//MIDIdef.freeAll;

	MIDIdef.noteOn(
		key: \noteOn,
		func: { arg vel, note;
			var node, partial;
	        node = notes.at(note);
			if ( node.notNil, { node.set(\gate,0); notes.put(note, nil) } );
			partial = note - 35; // start from 1
			notes[note] = Synth("addsynth", [
				\freq, ~fundamental * partial,
				\amp, vel.linlin(0, 127, 0.1,0.8),
				\att, ~att,
				\dec, ~dec,
				\sus, ~sus,
				\rel, ~rel,
				\lpfFreq, ~lpfFreq,
				\lpfRes, ~lpfRes])},
		noteNum: (29..127), // Ignore notes lower than 24 (= 46Hz)
		chan: ~quNeoChannel);

	MIDIdef.noteOff(
		key: \noteOff,
		func: {arg vel, note;
			notes[note].set(\gate,0);
			notes.put(note, nil);
		//("Note OFF "++ note).postln;
                },
		chan: ~quNeoChannel);

	MIDIdef.cc(
		key: \adsr,
		func: {arg val, ccnum;
			case
			{ccnum==6} {~att = val.linlin(0, 127, 0.01, 2)}
			{ccnum==7} {~dec = val.linlin(0, 127, 0.05, 1)}
			{ccnum==8} {~sus = val.linlin(0, 127, 0.25, 1)}
			{ccnum==9} {~rel = val.linlin(0, 127, 0.5, 2)}
			{ccnum==0} {~lpfFreq = val.linlin(0, 127, 0.1, 1.0)}
			{ccnum==1} {~lpfRes = val.linlin(0, 127, 0.0, 2.0)};
			[~att, ~dec, ~sus, ~rel, ~lpfFreq, ~lpfRes].round(0.01).postln},
		ccNum: [6,7,8,9,0,1]); // Vertical Sliders

	//pad controllers for various factors

   // vibrato add value + amplitude
	MIDIdef.cc(
		key: \synAmp,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the pressure controller to it's note.
			n = n + 35 ; // offset to 36
			//("cc is "++ ccnum).postln;
			notes[n].set(\vibAdd,  val.linlin(0, 127, 0.1, 0.6));
			notes[n].set(\lpfRes,  val.linlin(0, 127, 0.1, 0.9));
		},
		ccNum: Array.series(50,23,3));

		//[23,26,29,32,35,38,41,44,47,50,53,56,59,62,65,68]);
	// vibrato frequency
	MIDIdef.cc(
		key: \vibF,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the x controller to vibrato freq
			n = n + 35 ; // offset to 36
			//("Note is "++ n).postln;
			notes[n].set(\vibFreq,  val.linlin(0, 127, 0.05, 0.99));
		},
		ccNum: Array.series(50,24,3));

       // vibrato amplitude
		MIDIdef.cc(
		key: \vibA,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the y controller to the vibrato depth
			n = n + 35 ; // offset to 36
			//a("note is " ++ n).postln;
			notes[n].set(\vibAmp, val.linlin(0, 127, 0.1, 0.5));
		},
		ccNum: Array.series(50,25,3));


	MIDIdef.cc(
		key: \fundamental,
		func: {arg val, ccnum;
			~fundamental = val.linexp(0, 127, 55, 220);
			("Fundamental is "++~fundamental.round(0.1)++" Hz").postln},
		ccNum: 10);  // Long Slider

	// A synth

	SynthDef("addsynth", { arg freq = 440, amp = 0.1, gate = 1, att = 0.01, dec = 0.3, sus = 0.5, rel = 1,vibFreq=7, vibAmp=0,vibAdd=0.5,lpfFreq = 0.5, lpfRes = 0.5;
		var snd, env;
		lpfFreq = lpfFreq * (freq * 3) + ~fundamental;
		lpfRes = 1 - lpfRes * 0.9 + 0.1;
		env = EnvGen.ar(Env.adsr(att, dec, sus, rel, amp), gate, doneAction: 2);
		snd = SinOscFB.ar(freq, vibAmp, amp);
		snd = snd * SinOsc.kr(vibFreq*15, mul:vibAmp, add:vibAdd);
		snd = snd * env;
		//snd = snd * doneActionEnv * 0.5;
		Out.ar([0,1], RLPF.ar(snd, lpfFreq,lpfRes));
	}).add;

});
