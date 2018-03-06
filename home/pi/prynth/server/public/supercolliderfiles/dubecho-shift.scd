m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.5, \exp].asSpec;
t = [0.01, 0.5, \exp].asSpec;
p = [1/2, 3, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;
l = [0.1, 0.2, \lin].asSpec;
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
   /*
    phase = Sweep.ar(reset);
	fragmentlength = m.kr(0,1,g);// midi cntl 1
	reset = m.kr(0,2,t); // midi cntl 2 /// important that it is LATE :)
	rate = m.kr(0,3,r); // midi cntl 4
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
	DelayC.ar(snd, m.kr(0,0,p) , del); //midi cntl 3
	*/
{	var snd, reset;
	snd = SoundIn.ar([0,1]);
	//snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    reset = Onsets.kr(FFT(LocalBuf(512), snd), 0.7);
    snd = ~dubby.(snd, 1.0, 0.8);
    //snd = DelayC.ar(snd, 0.2, 0.2);
	snd!2 * 0.5; //+ SoundIn.ar([0,1]);

}.play;