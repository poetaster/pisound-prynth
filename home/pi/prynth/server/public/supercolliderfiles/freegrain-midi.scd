
//Quarks.install("CCIn");

m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.2, \exp].asSpec;
t = [0.5, 3.1, \exp].asSpec;
p = [1, 4, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;

~stutter = { | snd, reset, fragmentlength, rate = 1.0, maxdelay = 10 |
    var phase, fragment, del;
    phase = Sweep.ar(reset);
	fragmentlength = m.kr(0,1,g);// midi cntl 1
	reset = m.kr(0,2,t); // midi cntl 2 /// important that it is LATE :)
	rate = m.kr(0,3,r); // midi cntl 4
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
	DelayC.ar(snd, m.kr(0,0,p) , del); //midi cntl 3
};

{	var snd, reset;
	snd = SoundIn.ar([0, 1]);
	//snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    reset = Onsets.kr(FFT(LocalBuf(512), snd), 0.7);
    snd = ~stutter.(snd, reset, 0.09);
    snd = DelayC.ar(snd, 0.2, 0.2);
	snd!2 * 0.2 + SoundIn.ar([0,1],1);

}.play;

m = CCIn();
v = [300, 700, \exp].asSpec;
g = [0.01, 0.2, \exp].asSpec;
t = [0.5, 3.1, \exp].asSpec;
p = [1, 4, \exp].asSpec;
r = [0.5, 1.5, \exp].asSpec;


SynthDef(\prm_GrainFreeze, {
  |
  inBus = 0, outBus = 0, amp = 2,
  trigRate = 60, grainDur = 0.95, pos = 0.3, rate = 1,
  attackTime = 0.5, decayTime = 2, sustainLevel = 1, releaseTime = 2, gate = 1,
  lowPassCutoff = 7000, highPassCutoff = 100, postDistCutoff = 18000, distAmt = 1
  |

  var input, record, localBuf;
  var grainTrig, granulation, env, lpf, hpf, dist, sig;

  // Record (into a 1 second, mono buffer)
  input = In.ar(inBus, 1);
  localBuf = LocalBuf.new(SampleRate.ir * 1, 1).clear;
  record = RecordBuf.ar(input, localBuf, loop: 1);

  //// Granulate:
  // Random distribution of triggers prevents amplitude modulation artifacts
  grainTrig = Dust.ar(trigRate);
  granulation = GrainBuf.ar(1, grainTrig, grainDur, localBuf, rate, pos);

  // Filter and distort
  lpf = LPF.ar(granulation, lowPassCutoff);
  hpf = HPF.ar(lpf, highPassCutoff);
  dist = (hpf * distAmt).distort;
  dist = LPF.ar(dist, postDistCutoff);

  // Envelope -- delays start until recording has finished
  env = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
  sig = dist * env;

  // Output
  sig = Out.ar(outBus, sig);
}).add;

// execute this:
a = Bus.audio;
// then this:
b = { Out.ar(a, SoundIn.ar(0)) }.play;

// sing, whistle, or play a steady held note, then execute this line of code:
c = Synth(\prm_GrainFreeze, [\inBus, a, \outBus, 0, \attackTime, 10], addAction: \addToTail);



// play at half the speed, (one octave down):
c.set(\rate, 1.0);

// set lowpass cutoff:
c.set(\lowPassCutoff, 2500);

// set high pass cutoff:
c.set(\highPassCutoff, 1000);

// reset it:
c.set(\highPassCutoff, 20);

// set distortion (CAREFUL!! Gets loud):

c.set(\postDistCutoff, 1500);
c.set(\distAmt, 40.dbamp);


// increase release time and free:

c.set(\releaseTime, 10);
c.set(\gate, 0);


