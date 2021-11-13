SuperDirt.start;

Server.killAll;

// 出力先デバイスの確認
ServerOptions.outDevices;

// 出力先変更

(
Server.default.options.outDevice_("iRig HD 2");
Server.default.reboot;
SuperDirt.start;
)


(
Server.default.options.outDevice_("Soundflower (2ch)");
Server.default.reboot;
SuperDirt.start;
)

(
~dirt.loadSoundFiles("/Users/keitamiyano/Code/CodeMusic/SweetSoul/samples/*");

~dirt.addModule('SchroederReverb', { |dirtEvent|
	dirtEvent.sendSynth('SchroederReverb' ++ ~dirt.numChannels,
		[
			reverb: ~reverb,
			ice: ~ice,
			out: ~out
		]
	)
}, { ~reverb.notNil or: { ~ice.notNil }});
SynthDef("SchroederReverb" ++ ~dirt.numChannels, { |out, reverb, ice|
	var signal, chain, in, z, y, oct;
	signal = In.ar(out, ~dirt.numChannels);
	z = DelayN.ar(signal, 0.048);
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, 1, 15) }));
	32.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	oct = 1.0 * LeakDC.ar( abs(y) );
	y = SelectX.ar(ice, [y, ice * oct, DC.ar(0)]);
	signal = signal + (0.2*y*reverb);
	ReplaceOut.ar(out, signal)
}, [\ir]).add;

SynthDef("SinOscSynthBend", {
	arg out, sustain=1, decay=0, pan=0, freq=110, accelerate=0, slide=0, sustainpedal=0.5;
	var fglide, detune, sound, sig1, sig2, env, bendSustain;
	bendSustain = sustainpedal;
	detune = 1.001;
	fglide = EnvGen.ar(Env.perc(0.05, 0.3, 1, \lin), timeScale:bendSustain) * (-1*slide/4) + 1;
	freq = freq * fglide * Line.kr(1, 1+accelerate, bendSustain);
	sig1 = SinOsc.ar(freq).dup;
	sig2 = SinOsc.ar(freq * detune).dup;
	sound = (sig1 + sig2) * 0.5;
	env = EnvGen.ar(Env.linen(0.01, 0, 0.6, 1, -3), timeScale:sustain, doneAction:2);
	//env = EnvGen.ar(Env.pairs([[0,0],[0.03,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -1), timeScale:sustain, doneAction:2);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;

SynthDef("superhammondBend", {
	arg out, sustain=1, decay=0, pan, freq, vibrato=0.5, vrate=7, voice=0, perc=0, percf=2, accelerate=0, slide=0, sustainpedal=0.5;
	var freqs, amps, sound, click, env, ampscale, attrel, fglide, bendSustain;
	bendSustain = sustainpedal;
	// attrel = (sustain/2).clip(0,0.005);
	// env = EnvGen.ar(Env.linen(attrel, sustain-(2*attrel), attrel), doneAction:2);
	env = EnvGen.ar(Env.linen(0.1, sustain, 0.1, sustain), doneAction:2);
	fglide = EnvGen.ar(Env.perc(0.05, 0.3, 1, \lin), timeScale:bendSustain) * (-1*slide/4) + 1;
	freq = freq * fglide * Line.kr(1, 1+accelerate, bendSustain);
	freqs = [0.5, 1.4988, 1, 2, 2.9976, 4, 5.0409, 5.9953, 8, 1.001] * freq;
	freqs = 2**(freqs < 63) * freqs; // fold up bottom register
	freqs = freqs / (2**(freqs > 6000)); // fold down high harmonics
	freqs = freqs / (2**(freqs > 6000)); // do it again for the really high notes
	amps = SelectX.kr(voice, #[
		[1, 4, 5, 4, 3, 1, 0, 0, 0], // 0: bass violin 16'
		[0, 0, 8, 0, 4, 0, 0, 0, 0], // 1: tibia 8'
		[0, 7, 8, 1, 2, 0, 0, 0, 0], // 2: bassoon 8'
		[0, 0, 7, 8, 8, 8, 8, 7, 2], // 3: french trumpet 8'
		[4, 0, 5, 5, 4, 5, 3, 3, 6], // 4: string ensemble
		[8, 8, 5, 3, 2, 4, 5, 8, 8], // 5: Blues
		[8, 8, 8, 0 ,0, 0, 0, 0, 3], // 6: Jazz 1
		[8, 8, 8, 8, 8, 8, 8, 8, 8], // 7: Full Shout
		[8, 0, 0, 0, 0, 0, 8, 8, 8], // 8: Bro' Jack
		[0, 0, 8, 8, 0, 0, 0, 0, 0]  // 9: Jazz 2
	]);
	amps = amps - [0, 0, 0, 0, 0, 0, 0.5, 1, 1.5]; // damp brilliance a bit
	amps = 2**(amps-8);
	click = WhiteNoise.ar(1) * XLine.ar(1,1e-6, 0.1);
	sound = 0.5 * Mix.ar( SinOsc.ar(freqs, (2pi ! 9).rand, amps/amps.sum) );
	// オルガンサウンド特有のアタック音が欲しい場合
	//sound = 0.5 * Mix.ar( SinOsc.ar(freqs*(2*click+1), (2pi ! 9).rand, amps/amps.sum) );
	sound = perc * 0.5 * SinOsc.ar(freq*percf, 2pi.rand) * XLine.ar(1,1e-6,2*decay+1) + sound;
	sound = sound + BAllPass.ar(sound, 1000*LFTri.kr(vrate,0,vibrato/2,1));
	// panning
	sound = Pan2.ar(sound, FSinOsc.kr(1.43));
	Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;

SynthDef("MyMoog", {
	arg out, freq = 110, sustain = 1, pan = 0.5, pitch1=4.0, accelerate=0, slide=0, sustainpedal=0.5;
	var detune, sig1, sig2, env, sound, fglide, bendSustain;
	bendSustain = sustainpedal;
	fglide = EnvGen.ar(Env.perc(0.05, 0.3, 1, \lin), timeScale:bendSustain) * (-1*slide/4) + 1;
	freq = freq * fglide * Line.kr(1, 1+accelerate, bendSustain);
	detune = 1.005;
	sig1 = MoogFF.ar(
		Pulse.ar(freq, LFNoise1.ar(1.0,0.3,0.4)),
		freq*pitch1, 3
	).dup;
	sig2 = MoogFF.ar(
		Pulse.ar(freq, LFNoise1.ar(1.0,0.2,0.4)),
		freq*pitch1*1.5, 3
	).dup;
	sound = (sig1 + sig2) * 1;
	env = EnvGen.ar(Env.linen(0.01, 0, 0.6, 1, -3), timeScale:sustain, doneAction:2);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;

)
