// The fabulous MAWK Werkstatt-01 Synth Definition
(
SynthDef(\MAWK, { |out,
	// knobs
	freq = 220,
	freqoffset = 0,
	pwm = 0.5,
	cutoff = 4000,
	res = 0,
	amountVCOMod = 0.5,
	amountVCFMod = 0,
	lfoRate = 5,
	attack = 0.01,
	decay = 1.0
	sustain = 0,
	glide = 0,

	// switches
	oscSelect = 0, // 0 -> PULSE, 1 -> SAW
	vcaModeSelect = 0, // 0 -> ON, 1 -> EG

	vcoModSourceSelect = 1, // 0 -> EG, 1 -> LFO
	vcoModDestSelect = 1, // 0 -> PWM, 1 -> FREQ

	vcfModSourceSelect = 0, // 0 -> EG, 1 -> LFO
	vcfPolaritySelect = 0, // 0 -> +, 1 -> -

	lfoOscSelect = 0, // 0 -> SQUARE, 1 -> TRIANGLE
	//envSustainSelect -> 0 -> ON, 1 -> OFF, use sustain parameter instead

	gate = 1,
	amp = 0.1
	|

	// preprocess inputvalues and set select values (factos, that select sources and dests)
	var normLFORate = if((lfoRate <= 0.001), 0, lfoRate); // stop lfo, if freq below/equal 0.001 Hz
	var lfoSelectPulse = if((lfoOscSelect <= 0.01), 1, 0); // set lfo to Pulse
	var lfoSelectTri = if((lfoOscSelect >= 1), 1, 0); // set lfo to Tri

	var vcoSelectEGMod = if((vcoModSourceSelect <= 0.01), 1, 0); // select Pulse as Modulation source
	var vcoSelectLfoMod = if((vcoModSourceSelect >= 1), 1, 0); // select Tri as modulation source

	var vcoSelectPWMDest = if((vcoModDestSelect <= 0.01), 1, 0); // select PWM as Modulation dest
	var vcoSelectFreqDest = if((vcoModDestSelect >= 1), 1, 0); // select Freq as Modulation des

	var vcfSelectEGMod = if((vcfModSourceSelect <= 0.01), 1, 0); // select EG as filter modulation source
	var vcfSelectLfoMod = if((vcfModSourceSelect >= 1), 1, 0); // select LFO as filter modulation source


	// MODULATORS come first
	// envelope as adsr, decay and release depend on sustain on/off
	var env_params = Env.adsr(attack, decay, (1 - sustain), decay, 1.0, -4.0);
    var env = EnvGen.kr(env_params, gate, doneAction: Done.freeSelf);

	// Modulation values for
	var envVCOModVal = (env * amountVCOMod) * vcoSelectEGMod; // multiply env by Amount (0-1)
	var envFilterModVal = (env * amountVCFMod) * vcfSelectEGMod; // multiply env by Amount (0-1)

	// lfo, two oscilators: LFPulse and Saw
	var lfo1 = LFPulse.ar(normLFORate, 0.5, width: 0.5, mul: 1.0, add: 0.0) * lfoSelectPulse;
	var lfo2 = LFTri.ar(normLFORate, 0, mul: 1, add: 0) * lfoSelectTri;
	var lfo_env_params = Env.adsr(0.0001, 0, 1, decay, 1.0, -4.0); // lfo env is need to restart the lfo with every key step
    var lfo_env = EnvGen.kr(lfo_env_params, gate, doneAction: Done.freeSelf);
	var lfosig = (lfo1 + lfo2) * lfo_env; // mix them
	var lfoVCOModVal = (lfosig * amountVCOMod) * vcoSelectLfoMod; // multiply lfo by Amount (0-1)
	var lfoFilterModVal = (lfosig * amountVCFMod) * vcfSelectLfoMod; // multiply lfo by Amount (0-1)


	// calculate the modulations values
	var vcoPWMMod = if(vcoSelectPWMDest>=1,(lfoVCOModVal + envVCOModVal).linlin(0,1,0.1,0.9), pwm);
	var vcoFreqMod = if(vcoSelectFreqDest>=1, (lfoVCOModVal + envVCOModVal), 0);
	var vcfCutoffMod = (lfoFilterModVal + envFilterModVal).linlin(0,1,0,2);


	// SOUND SOURCES second
	// two oscilators: Pulse and Saw
	var vco1 = Pulse.ar(freqoffset + (freq * (1+ vcoFreqMod)), width: vcoPWMMod, mul: 1.0, add: 0.0) * (1 - oscSelect);
	var vco2 = Saw.ar(freqoffset + (freq * (1 + vcoFreqMod)), mul: 1.0, add: 0.0) * oscSelect;
	var sig = (vco1 + vco2); // mix them


	// FILTERS THIRD
	var vcf =  MoogFF.ar(sig, cutoff * (1 + vcfCutoffMod), res, 0, 1, 0);

	// LAST: MIXING IT ALL
	Out.ar(out!2, vcf * env * amp)
}).add
)

// Test synth functionality
a = Synth(\MAWK, [\sustain, 0]) // do not use sustain, AD only

a = Synth(\MAWK, [\sustain, 1]) // use sustain ASR until gate == 0
a.set(\gate, 1); // set gate to 0, release key, start release phase
a.set(\gate, 0); // set gate to 0, release key, start release phase

a.set(\freq, 220); // set freq to 220 Hz
a.set(\freq, 440); // set freq to 440 Hz, Kammerton
a.set(\freq, 60.midicps); // set freq to midi key 60, middle C

a.set(\oscSelect, 0) // select PULSE
a.set(\oscSelect, 1) // select SAW
a.set(\pwm, 0.7); // set PWM

a.set(\cutoff, 1000); // set cutoff
a.set(\cutoff, 8000); // set cutoff

a.set(\res, 0); // set res to 0, minimum
a.set(\res, 1); // set res to 1
a.set(\res, 2); // set res to 2
a.set(\res, 3); // set res to 3
a.set(\res, 4); // set res to 4, maximum

a.set(\vcoModSourceSelect, 1); // set vco Modulation to lfo
a.set(\vcoModSourceSelect, 0); // set vco Modulation to eg

a.set(\lfoRate, 0.1); // set lfoRate to 4
a.set(\amountVCOMod, 0.1); // set amount of lfo Modulation to 2 (one octave!)
a.set(\lfoOscSelect, 0); // set lfo waveform to PULSE
a.set(\lfoOscSelect, 1); // set lfo waveform to TRIANGLE

a.free;

16.midicps
127.midicps
Done.freeSelf;



{ LFPulse.ar(40, iphase:0.5) }.plot(0.1);
{ LFTri.ar(40).abs }.plot(0.1);