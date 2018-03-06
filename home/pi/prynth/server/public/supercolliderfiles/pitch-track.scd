
SynthDef(\pitchTrack, {
	var soundin = SoundIn.ar(0);
	var zc = ZeroCrossing.ar(soundin);
	// var pt = Pitch.kr(soundin);
	// var tt = Tartini.kr(soundin);
	SendReply.kr(Impulse.kr(1), '/pitchTrackUtil', [zc, zc.cpsmidi]);
}).add;
(
~pitchTrack = {
	if(~pitchTrackSynth.isNil or: { ~pitchTrackSynth.isRunning.not }, {
		~pitchTrackSynth = Synth(\pitchTrack);
		~pitchTrackNW = NodeWatcher.register(~pitchTrackSynth);
	}, {
		~pitchTrackSynth.free;
		~pitchTrackSynth = nil;
		"Pitch tracker stopped.".postln;
	});
};

~pitchTrackOSCFunc = {
	OSCFunc({
		| msg |
		("Pitch:"+msg[3].round.asString.padLeft(5)+msg[4].round.asString.padLeft(3)).postln;
	}, '/pitchTrackUtil');
};
)

~pitchTrackOSCFunc.();

~pitchTrack.();

CmdPeriod.add({~pitchTrackOSCFunc.();});

