
MIDIIn.connectAll;
b = Buffer.readChannel(s, "/usr/share/puredata/doc/sound/voice.wav", channels: [0]);

SynthDef(\g_samp, {
	arg trigger = 10, dur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1, gate = 1, attackTime = 0.1, decayTime = 0.5, sustainLevel = 0.5, releaseTime = 0.5;
	var env, snd;
	//env = EnvGen.kr(Env.asr, gate, levelScale: amp, doneAction: 2);
	env = EnvGen.kr(Env.adsr(attackTime, decayTime, amp, releaseTime), gate, doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(trigger),
		dur: dur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
	Out.ar(0, snd * env);
}).add;


(
var keys;
keys = Array.newClear(128);

c = CCResponder({ |src,chan,num,value|
        [src,chan,num,value].postln;
        },
        nil, // any source
        nil, // any channel
	    { |num | num < 60 }, // CC number 80
        { |value| value < 100 } // any value less than 50
);


~noteOnFunc = {arg val, num, chan, src;
	var node, amp, transpose;
	node = keys.at(num);
	if (node.notNil, {
		node.release;
		keys.put(num, nil);
	});
	amp = val/127;
	transpose = num/32;
	node = Synth(\g_samp,
		[\transp, transpose,\trigger, 100,\sndbuf, b,\amp, amp,\dur, 0.1,\pos, amp * rrand(0.1,0.2)]);
	keys.put(num, node);
};

MIDIdef.noteOn(\on, ~noteOnFunc);

~noteOffFunc = {arg val, num, chan, src;
	var node;
	node = keys.at(num);
	if (node.notNil, {
		node.release;
		keys.put(num, nil);
	});
};

MIDIdef.noteOff(\off, ~noteOffFunc);
)