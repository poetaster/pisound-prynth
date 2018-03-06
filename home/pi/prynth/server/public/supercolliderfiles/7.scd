
//Quarks.install("CCIn");

m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.4, \exp].asSpec;
t = [0.5, 3.1, \exp].asSpec;
p = [1, 4, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;

i = [0.5, 2.0, \lin].asSpec; // pitch for shift
j = [0.01, 0.2, \lin].asSpec; // p displacement
k = [0.01, 0.2, \lin].asSpec; // time displacement

~stutter = { | snd, reset, fragmentlength, rate = 1.0, maxdelay = 10 |
    var phase, fragment, del;
    phase = Sweep.ar(reset);
	fragmentlength = m.kr(0,1,g);// midi cntl 1
	reset = m.kr(0,2,t); // midi cntl 2 /// important that it is LATE :)
	rate = m.kr(0,3,r); // midi cntl 4
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
	PitchShift.ar( DelayC.ar(snd, m.kr(0,0,p) , del), 0.2, m.kr(0,4,i), m.kr(0, 5, j), m.kr(0, 6, k));
	//DelayC.ar(snd, m.kr(0,0,p) , del); //midi cntl 3
};

{	var snd, reset;
	snd = SoundIn.ar(0);
	//snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    reset = Onsets.kr(FFT(LocalBuf(512), snd), 0.7);
    snd = ~stutter.(snd, reset, 0.09);
    snd = DelayC.ar(snd, 0.2, 0.2);
	snd!2 * 0.2 + SoundIn.ar([0,1],1);

}.play;



