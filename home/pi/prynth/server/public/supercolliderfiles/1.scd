m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.5, \exp].asSpec;
t = [0.01, 0.5, \exp].asSpec;
p = [1/2, 3, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;
l = [0.1, 0.3, \lin].asSpec;
f = [0.2, 1.2, \lin].asSpec;
~dubby = { | snd, reset, fb = 0.9, rate = 1.0, maxdelay = 10 |
     var phase, fragment, del, out,magic;
     snd + Fb({
		arg feedback; // this will contain the delayed output from the Fb unit
		// filter and distort the feedback signal.
		// Note that the input signal is fed in here as well:
		magic = LeakDC.ar(PitchShift.ar(snd, 0.2, m.kr(0,1,p), m.kr(0, 2, g), m.kr(0, 3, t) ) + 
		(PitchShift.ar(feedback, 0.2, m.kr(0,1,p), m.kr(0, 2, g), m.kr(0, 3, t) ) * m.kr(0,6,f)));
        magic = HPF.ar(magic, 400); // filter's on the feedback path
        magic = LPF.ar(magic, 5000);
        magic = magic.tanh; // and some more non-linearity in the form of distortion
		//BPF.ar(feedback*0.9 + snd, 2000, 3.8); //.distort;
		// for fun effects, try changing the 0.8 to something greater than one
	},m.kr(0, 5, l));
	//magic;
};
{	var snd;
	snd = SoundIn.ar([0,1]);
	//snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    snd = ~dubby.(snd, 1.0, 0.8);
	snd!2 * 0.5;

}.play;
