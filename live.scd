(
SynthDef("sine", {
	arg freq = 440, amp = 0.2, parFreq=0, pan2Freq=0,
	vibratoFreq=3, vibratoDepth=0, actave=1, reverb=0, ice=0;
	var sig, out=0, chain, in, z, y, oct;
	sig = SinOsc.ar(actave*freq*(1+((LFPar.ar(vibratoFreq)+1)*(vibratoDepth/50))), 0, amp);
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
	// reverb
	z = DelayN.ar(sig, 0.048);
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, 1, 15) }));
	32.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	oct = 1.0 * LeakDC.ar( abs(y) );
	y = SelectX.ar(ice, [y, ice * oct, DC.ar(0)]);
	sig = sig + (0.2*y*reverb);
    Out.ar(out, sig);
}, [0.3, 2, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 1]).add;
)

// livecoding

x = Synth("sine", [\freq, 659.255, \amp, 0, \parFreq, 0, \pan2Freq, 1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.2]);
x.set(\amp, 0.1);
x.set(\reverb, 0.4);
x.set(\ice, 0.2);
x.set(\parFreq, 0);
x.set(\pan2Freq, 0);
x.set(\pan2Freq, 164.814/16);
y = Synth("sine", [\freq, 880, \amp, 0, \parFreq, 0, \pan2Freq, 1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.2]);
y.set(\amp, 0.08);
y.set(\pan2Freq, 1);

x.set(\amp, 0);
y.set(\amp, 0);

// 実験
x = Synth("sine", [\freq, 659.255, \amp, 0, \parFreq, 0, \pan2Freq, 1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.2]);
x.set(\amp, 0);
x.set(\amp, 0.1);
x.set(\reverb, 0.5);
x.set(\ice, 0);
x.set(\vibratoDepth, 0.3);
x.set(\vibratoFreq, 3);
x.set(\parFreq, 10);
x.set(\pan2Freq, 164.814);
x.set(\freq, 164.814); // E3
x.set(\freq, 659.255/2); // E4
x.set(\freq, 659.255); // E5
x.set(\freq, 493.883); // B4
x.set(\freq, 493.883*2); // B5
x.set(\freq, 830.609/2); // G#4
x.set(\freq, 830.609); // G#5
x.set(\freq, 220); // A3
x.set(\freq, 440); // A4
x.set(\freq, 880); // A5
x.set(\freq, 987.767); // B5
x.set(\freq, 1318.510); // E6
x.set(\freq, 1661.219); // G#6
x.set(\freq, 1760); // A6

