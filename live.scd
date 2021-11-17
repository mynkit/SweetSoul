(
SynthDef("sine", {
	arg freq = 440, amp = 0.12, parFreq=0, pan2Freq=0;
	var sig, out=0;
	sig = SinOsc.ar(freq, 0, amp);
	// tremoro
	sig = if(
		parFreq>0.1,
		sig*LFPar.ar(parFreq),
		if(
			LFPar.ar(parFreq)>0,
			sig*(LFPar.ar(parFreq) + (1-(LFPar.ar(parFreq))*((1-(parFreq*10))))),
			sig*(LFPar.ar(parFreq) + (-1-(LFPar.ar(parFreq))*((1-(parFreq*10))))),
		)
	);
	// panning
	sig = if(
		pan2Freq>0.1,
		Pan2.ar(sig, LFPar.ar(pan2Freq)),
		Pan2.ar(sig, LFPar.ar(pan2Freq)*pan2Freq*10)
	);
    Out.ar(out, sig);
}, [0.1, 0.3, 0.3, 0.3]).add;
)

x = Synth("sine", [\freq, 440, \amp, 0.1, \parFreq, 0.5, \pan2Freq, 0]);
x = Synth("sine", [\freq, 440, \amp, 0.1, \parFreq, 0, \pan2Freq, 0.5]);
x.set(\amp, 0);
x.set(\amp, 0.1);
x.set(\parFreq, 0);
x.set(\pan2Freq, 0);
x.set(\freq, 660, \amp, 0.08);
x.set(\freq, 440, \amp, 0.1);
x.set(\freq, 344, \amp, 0.11);


