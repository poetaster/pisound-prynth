m = CCIn();

v = [0, 225, \exp].asSpec;
~pitchDisp = { |cc=0,amount=0.5|
	m.kr(0, 0, v);
};

t = [0.1, 2.0, \exp].asSpec;
~timeDisp = { |cc=1,amount=0.5|
	m.kr(0, 1, t);
};
		
g = [0, 0.9, \exp].asSpec;
~grainDisp = { |cc=2,amount=0.5|
	m.kr(0, 2, g);
};

{ var snd = SoundIn.ar([0, 1]);
  PitchShift.ar(
		snd,
		~grainDisp,
		1,                        // nominal pitch rate = 1
		~pitchDisp,             // pitch dispersion
		~timeDisp    // time dispersion
		)}.play;

