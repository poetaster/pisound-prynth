// ************************************
// Wavetable Synthesis Demo with QuNEO
// based on patch by http://sccode.org/1-4UO Bruno Ruviaro, 2013-07-22
// this version, blueprint@poetaster.de
// ************************************

/*
Use QuNEO Preset #1 for 3d pad play

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


	// Some variables

	var notes = Array.newClear(64);
	var ints = Array.series(16, 36, 1);

	~att = 0.01;
	~dec = 0.3;
	~sus = 0.5;
	~rel = 1.0;
	~lpfFreq = 5.0;
	~lpfRes = 0.5;
	~fundamental = 110;
	~quNeoChannel = 0;
     s = Server.local;
/*	
	~tableOne = {
    // allocate and fill tables 0 to 7
      8.do({ arg i;
      var n, a;
    
      s.sendMsg(\b_alloc, i, 1024);
      // generate array of harmonic amplitudes
      n = (i+1)**2;
      a = Array.fill(n, { arg j; ((n-j)/n).squared.round(0.001) });
      // fill table
      s.performList(\sendMsg, \b_gen, i, \sine1, 7, a);});
	};
	*/
	
	
		8.do({ arg i;
			var a;
			s.sendMsg(\b_alloc, i, 1024); // allocate table
			// generate array of harmonic amplitudes
			a = Array.fill(i, 0) ++ [0.5, 1, 0.5];
			// fill table
			s.performList(\sendMsg, \b_gen, i, \sine1, 7, a);
		});

/*	
	~tableThree = {
		8.do({ arg i;
			var a, n;
			s.sendMsg(\b_alloc, i, 1024); // allocate table
			// generate array of harmonic amplitudes
			n = (i+1)*8;
			a = Array.fill(n,0);
			(n>>1).do({ arg i; a.put(n.rand, 1) });
			// fill table
			s.performList(\sendMsg, \b_gen, i, \sine1, 7, a);
		});
	};
	
	~tableFour = {
		8.do({ arg i;
			var a;
			s.sendMsg(\b_alloc, i, 1024); // allocate table
			// generate array of harmonic amplitudes
			n = (i+1)**2;
			a = Array.fill(n, { arg j; 1.0.rand2 });
			// fill table
			s.performList(\sendMsg, \b_gen, i, \sine1, 7, a);
		});
	};
*/	
	MIDIIn.connectAll;

	//MIDIdef.freeAll;

	MIDIdef.noteOn(
		key: \noteOn,
		func: { arg vel, note;
			var node, partial;
	        node = notes.at(note);
			if ( node.notNil, { node.release; notes.put(note, nil) } );
			partial = note - 35; // start from 1
			notes[note] = Synth("addsynth", [
				//\freq, (~fundamental * partial) + (partial*2),
				\freq, Scale.partch_o1.degreeToFreq(2, (note - 5).midicps, 1),
				\amp, vel.linlin(0, 127, 0.05,0.9),
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
			notes[note].release;
			notes.put(note, nil);
		//("Note OFF "++ note).postln;
		},
		chan: ~quNeoChannel);

	MIDIdef.cc(
		key: \adsr,
		func: {arg val, ccnum;
			case
			{ccnum==6} {~att = val.linlin(0, 127, 0.01, 3)}
			{ccnum==7} {~dec = val.linlin(0, 127, 0.05, 0.9)}
			{ccnum==8} {~sus = val.linlin(0, 127, 0.25, 0.9)}
			{ccnum==9} {~rel = val.linlin(0, 127, 0.5, 3)}
			{ccnum==0} {~lpfFreq = val.linlin(0, 127, 2.0, 5.0)}
			{ccnum==1} {~lpfRes = val.linlin(0, 127, 0.1, 1.0)};
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
			//notes[n].set(\vibAdd,  val.linlin(0, 127, 0.0, 0.3));
			notes[n].set(\lpfRes,  val.linlin(0, 127, 0.1, 0.99));
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
			notes[n].set(\vibFreq,  val.linlin(0, 127, 0.05, 0.3));
			
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
			notes[n].set(\bufof, val.linlin(0, 127, 0.0, 4.0));
		},
		ccNum: Array.series(50,25,3));


	MIDIdef.cc(
		key: \fundamental,
		func: {arg val, ccnum;
			~fundamental = val.linexp(0, 127, 55, 220);
			("Fundamental is "++~fundamental.round(0.1)++" Hz").postln},
		ccNum: 10);  // Long Slider

	// A synth

	SynthDef("addsynth", { arg freq = 440, amp = 0.1, gate = 1, att = 0.01, dec = 0.3, sus = 0.5, rel = 1,vibFreq=7, vibAmp=0,vibAdd=0.5,lpfFreq = 0.5, lpfRes = 0.5,bufof=0;
		var snd, env;
		lpfFreq = lpfFreq * (freq * 3) + ~fundamental;
		lpfRes = 1 - lpfRes * 0.9 + 0.1;
		env = EnvGen.ar(Env.adsr(att, dec, sus, rel, amp), gate, doneAction: 2);
		snd = VOsc3.ar(bufof, freq+1,freq+vibFreq,freq+vibAmp, amp);
		//snd = SinOscFB.ar(freq, vibAmp, amp);
		snd = snd * SinOsc.kr(vibFreq*15, mul:vibAmp);
		snd = snd * env;
		//snd = snd * doneActionEnv * 0.5;
		Out.ar([0,1], RLPF.ar(snd, lpfFreq,lpfRes));
	}).add;
	

