// midi part
MIDIIn.connectAll;
(
// array has one slot per possible MIDI note
var midiSamplerArray = Array.newClear(128);

// MIDI processing
MIDIdef.noteOn(key: \sampleOn,
	func: { arg velocity, noteNumber, chan;



		// drums on chan 9
		if(chan==9, {
			if(noteNumber==36,{ "bd: ".post; Synth(\kick, [\amp, 0.7, \dur, 0.25]);}); // BassDrum
			if(noteNumber==37,{ "bd1: ".post; Synth(\kick, [\amp, 0.2, \dur, 0.25]);}); // soft BaseDrum
			if(noteNumber==38,{ "snare: ".post; Synth(\snare, [\amp, 0.7, \dur, 0.25]);}); // Sanre
			if(noteNumber==39,{ "hat: ".post; Synth(\hat, [\amp, 0.7, \dur, 0.1]);}); // HiHat
			if(noteNumber==40,{ "tom: ".post; Synth(\tom, [\amp, 0.2, \dur, 0.3]);}); // Tom

			if(noteNumber==41,{ "\moth_snare: ".post; Synth(\moth_snare, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==42,{ "\moth_kick: ".post; Synth(\moth_kick, [\amp, 0.2, \dur, 0.3]);}); // Tom

			if(noteNumber==43,{ "\elektro_kick: ".post; Synth(\elektro_kick, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==44,{ "\elektro_snare: ".post; Synth(\elektro_snare, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==45,{ "\elektro_hihat: ".post; Synth(\elektro_hihat, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==46,{ "\elektro_clap: ".post; Synth(\elektro_clap, [\amp, 0.2, \dur, 0.3]);}); // Tom

			if(noteNumber==47,{ "\soft_hihat: ".post; Synth(\soft_hihat, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==48,{ "\soft_snare: ".post; Synth(\soft_snare, [\amp, 0.2, \dur, 0.3]);}); // Tom
			if(noteNumber==49,{ "\soft_kick: ".post; Synth(\soft_kick, [\amp, 0.2, \dur, 0.3]);}); // Tom
		});


		// sound on chan 0,1,2,3
		if(chan<=3,{
			var mawk1 = Synth(\MAWK,[
				\freq, noteNumber.midicps,
				\freqoffset, ~freqoffset,
				\amp, velocity.linlin(0, 127, 0, 0.1),
				\attack, ~attack,
				\decay, ~decay,
				\sustain, ~sustain,
				\oscSelect, ~oscSelect,
				\pwm, ~pwm,
				\cutoff, ~cutoff,
				\res, ~res,
				\lfoRate, ~lfoRate,
				\lfoOscSelect, ~lfoOscSelect,
				\vcoModSourceSelect, ~vcoModSourceSelect,
				\vcoModDestSelect, ~vcoModDestSelect,
				\amountVCOMod, ~amountVCOMod,
				\vcfModSourceSelect, ~vcfModSourceSelect,
				\amountVCFMod, ~amountVCFMod,
			]);
			var mawk2 = Synth(\MAWK,[
				\freq, (noteNumber-0).midicps * (1.0 + ~detune),
				\freqoffset, ~freqoffset,
				\amp, velocity.linlin(0, 127, 0, 0.1),
				\attack, ~attack,
				\decay, ~decay,
				\sustain, ~sustain,
				\oscSelect, ~oscSelect,
				\pwm, ~pwm,
				\cutoff, ~cutoff,
				\res, ~res,
				\lfoRate, ~lfoRate,
				\lfoOscSelect, ~lfoOscSelect,
				\vcoModSourceSelect, ~vcoModSourceSelect,
				\vcoModDestSelect, ~vcoModDestSelect,
				\amountVCOMod, ~amountVCOMod,
				\vcfModSourceSelect, ~vcfModSourceSelect,
				\amountVCFMod, ~amountVCFMod,
			]);


			midiSamplerArray[noteNumber] = List[mawk1, mawk2];

		}); // control synth



		noteNumber.post; " ".post;chan.postln;
});

MIDIdef.noteOff(key: \sampleOff,
	        func: { arg velocity, noteNumber, chan;

		if(chan<=3, {
			midiSamplerArray[noteNumber][0].set(\gate, 0);
			midiSamplerArray[noteNumber][1].set(\gate, 0);
			midiSamplerArray[noteNumber][0] = nil;
			midiSamplerArray[noteNumber][1] = nil;
		});
});


~oscNames = List["PULSE", "SAW"];
~lfoNames = List["PULSE", "TRIANGLE"];
~modSourceNames = List["EG", "LFO"];
~modDestNames = List["PWM", "FREQ"];
~onOff = List["ON", "OFF"];

~freqoffset = 0;
~attack = 0.01;
~decay = 0.5;
~sustain = 0;
~cutoff = 4000;
~lfoRate = 0;
~lfoOscSelect = 0;
~vcoModSourceSelect = 0;
~vcoModDestSelect = 0;
~amountVCOMod = 0;
~vcfModSourceSelect = 0;
~amountVCFMod = 0;
~res = 2;
~oscSelect = 0;
~pwm = 0.5;

~detune = 0;



MIDIdef.cc(key: \ccTest,
	func: { arg value, ccNum, chan;
		chan.post;" ".post;
		value.post;" ".post;
		value.post;" ".post;
		ccNum.postln;

		// launch control
		if(ccNum==21,{ ~attack = value.linexp(0,127, 0.01, 2 ); "attack: ".post; ~attack.postln;}); // ATTACK
		if(ccNum==22,{ ~decay = value.linlin(0,127, 0.01, 5 ); "decay: ".post; ~decay.postln;}); // DECAY
		if(ccNum==23,{ ~oscSelect = if((value.linlin(0,127, 0, 2) > 1), 1,0); "oscSelect: ".post; ~oscNames[~oscSelect].postln;});
		if(ccNum==24,{ ~sustain = if((value.linlin(0,127, 0, 2) > 1), 1,0); "sustain: ".post; ~onOff[~sustain].postln;});
		if(ccNum==25,{ ~pwm = value.linlin(0,127, 0.1, 0.90); "pwm: ".post; ~pwm.postln;}); // DECAY
		if(ccNum==26,{ ~cutoff = value.linexp(0,127, 10, 20000 );"cutoff ".post; ~cutoff.postln;});
		if(ccNum==27,{ ~res = value.linexp(0, 127, 0.001, 4);"res ".post; ~res.postln;});
		if(ccNum==28,{ ~detune = value.linexp(0, 127, 0.000001, 0.5);"detune ".post; ~detune.postln;});

		if(ccNum==41,{ ~lfoRate = value.linexp(0, 127, 0.001, 40);"lfoRate ".post; ~lfoRate.postln;});
		if(ccNum==42,{ ~lfoOscSelect = if((value.linlin(0,127, 0, 2) > 1), 1,0); "lfoOscSelect: ".post; ~lfoNames[~lfoOscSelect].postln;});
		if(ccNum==43,{ ~amountVCOMod = value.linlin(0, 127, 0, 1);"amountVCOMod ".post; ~amountVCOMod.postln;});

		if(ccNum==44,{ ~vcoModSourceSelect = if((value.linlin(0,127, 0, 2) > 1), 1,0); "vcoModSourceSelect: ".post; ~modSourceNames[~vcoModSourceSelect].postln;});
		if(ccNum==45,{ ~vcoModDestSelect = if((value.linlin(0,127, 0, 2) > 1), 1,0); "vcoModDestSelect: ".post; ~modDestNames[~vcoModDestSelect].postln;});


		if(ccNum==46,{ ~vcfModSourceSelect = if((value.linlin(0,127, 0, 2) > 1), 1,0); "vcfModSourceSelect: ".post; ~modSourceNames[~vcfModSourceSelect].postln;});
		if(ccNum==47,{ ~amountVCFMod = value.linlin(0, 127, 0, 1);"amountVCFMod ".post; ~amountVCFMod.postln;});

		if(ccNum==1,{  ~freqoffset = value.linlin(0, 127, 0, 2000);"freqoffset ".post; ~amountVCOMod.postln;});

		// update all synths
		"update".postln;
		midiSamplerArray.do({arg synth;
			if( synth != nil , {
				synth[0].set(\pwm, ~pwm);
				synth[0].set(\cutoff, ~cutoff);
				synth[0].set(\res, ~res);
				synth[0].set(\lfoRate, ~lfoRate);
				synth[0].set(\lfoOscSelect, ~lfoOscSelect);
				synth[0].set(\amountVCOMod, ~amountVCOMod);
				synth[0].set(\freqoffset, ~freqoffset);
				synth[0].set(\vcoModSourceSelect, ~vcoModSourceSelect);
				synth[0].set(\vcoModDestSelect, ~vcoModDestSelect);
				synth[0].set(\vcfModSourceSelect, ~vcfModSourceSelect);
				synth[0].set(\amountVCFMod, ~amountVCFMod);


				synth[1].set(\pwm, ~pwm);
				synth[1].set(\cutoff, ~cutoff);
				synth[1].set(\res, ~res);
				synth[1].set(\lfoRate, ~lfoRate);
				synth[1].set(\lfoOscSelect, ~lfoOscSelect);
				synth[1].set(\amountVCOMod, ~amountVCOMod);
				synth[1].set(\freqoffset, ~freqoffset);
				synth[1].set(\vcoModSourceSelect, ~vcoModSourceSelect);
				synth[1].set(\vcoModDestSelect, ~vcoModDestSelect);
				synth[1].set(\vcfModSourceSelect, ~vcfModSourceSelect);
				synth[1].set(\amountVCFMod, ~amountVCFMod);
			});
		});
	}
);
)

