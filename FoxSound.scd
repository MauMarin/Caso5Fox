
/*
Para que suene, se tiene que instalar y correr LoopBe1
https://www.nerds.de/en/loopbe1.html

Descarga (último ejecutable):
https://www.nerds.de/en/download.html

Correr programa en el siguiente orden:

1) MIDIClient.init;
2) m = MIDIOut(1);
3) Los synths
4) Todas las funciones: caminar, correr...
5) Ejecute el archivo de processing
6) El default run (Vea la animación con el sonido)
7) Corridas modulares

*/

MIDIClient.init;

m = MIDIOut(1);


//---------------------------------Synths------------------------------------------------------

(


SynthDef.new(\snow, { //Sonido de los pasos en la nieve, similar al sonido del vapor
	|out = 0|
	var son=(
		DelayC.ar(LPF.ar(WhiteNoise.ar([1,1]))*EnvGen.ar(Env.new([0,0.7,0.1,0],[0.1,0.5,0.5]), doneAction:2),0.2,0.2,1)
		+LPF.ar(WhiteNoise.ar([1,1]))*EnvGen.ar(Env.new([0,0.7,0.1,0],[0.1,0.5,0.5]), doneAction:2)
	);
	Out.ar(out,son*0.2);
}).add;

SynthDef(\jump, { //Salto
		| attack=0.3, decay=0.1, freq=400, amp=0.025|
	var pitch, son, filter;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.05), doneAction: 2); //envelope con delay
	pitch = freq * EnvGen.ar(Env.new([0,1],[1]).exprange(1, 2.718), timeScale: 0.5); //La frequencia del sonido para que tenga forma exponencial
	filter = TwoPole.ar(TwoZero.ar(SinOsc.ar(pitch) , radius: 0.4), 0.8); //filtros para que el sonido sea más fino y claro
	son = HPF.ar(filter, 500) * amp * 10;
	Out.ar([0,1], son*0.5);
}).add;


SynthDef(\down, { //Bajada del salto
		|attack=0.4, decay=0.1, freq=1000, amp=0.025| //Es igual que el jump pero con el envolvente al revés, el ataque y el delay invertidos
	var pitch, son, filter;
	amp   = amp * EnvGen.ar(Env.perc(decay, attack).delay(0.003), doneAction: 2);
	pitch = freq * EnvGen.ar(Env.new([1,0,0],[1,0]).exprange(1, 2.718), timeScale: 0.5);
	filter = TwoPole.ar(TwoZero.ar(FreeVerb.ar(SinOsc.ar(pitch), mix: 0.5, room: 0.7, damp: 0.7), radius: 0.4), 0.8); //filtros para que el sonido sea más fino y claro, además tiene un Reverb
	son = HPF.ar(filter, 500) * amp * 10;
	Out.ar([0,1], son);
}).add;

SynthDef(\sniff_in, { //olfateo: inhalar
	var env, noise, s1, s2, s3, s4;
	env = EnvGen.kr(Env.new([0,1,1,0],[0.05, 0.05, 0.05]),doneAction:Done.freeSelf);
	noise = WhiteNoise.ar(0.3);
	s1 = HPF.ar(in:noise, freq:5790, mul:0.1);
	s2 = BPF.ar(in:noise, freq:3400, rq:0.005, mul:0.2); //dos BPF para darle un tono suave, como sonido del viento
	s3 = BPF.ar(in:noise, freq:1990, rq:0.01, mul:0.2);
	s4 = LPF.ar(in:noise, freq:1250, mul:0.1);
	Out.ar([0,1], Pan2.ar(env*(s1+s2+s3+s4)));
}).add;

SynthDef(\sniff_out, { //olfateo: exhalar
	| dur=0.05 |
	var env, noise, s1, s2, s3;
	env = EnvGen.kr(Env.new([0, 1, 0], [dur,dur]), doneAction:Done.freeSelf);
	noise = WhiteNoise.ar(0.3);
	s1 = LPF.ar(in:noise, freq:2290, mul:0.2);
	s2 = HPF.ar(in:noise, freq:1290, mul:0.2);
	s3 = LPF.ar(in:noise, freq:490, mul:0.2); //LPF para darle un sonido más fuerte, más cercano
	Out.ar(0, Pan2.ar(env*(s1+s2+s3)));
}).add;


SynthDef.new(\crash, { //choque contra la nieve, parecido a los pasos en la nieve, pero con otro filtro y otro envolvente
	var son, env;
	env = Env.perc(0.05, 1, 1, -4);
	son = WhiteNoise.ar([1,1]) + WhiteNoise.ar([1,1])* EnvGen.kr(env);
	son = Mix.ar(BPF.ar(son,[100,1200,80,40,20],0.5,[1,0.2,1,1,1])); //frecuencias centrales [100,1200,80,40,20] con diferentes amplitudes [1,0.2,1,1,1] para atenuar el sonido
	Out.ar([0,1], son);
}).add;

)




//---------------------------------Sonido------------------------------------------------------

//---------------CAMINAR------------------------

(w = { arg n = 6;
(
    fork {
	    x = 50; //notas del piano empiezan en 50
		n.do({

		Pbind(
			\freq, Pseq([[x + 3,x + 6]].midicps), //Notas en piano con tonos que van incrementando (para causar suspenso)
			\dur, 1,
			\releaseTime, 1,
			\pan, 1
		).play;
		0.2.wait;
		//suena la nieve al ritmo de los pasos
		m.noteOn(0, 20, 0);
		Synth(\snow);
		0.15.wait;
		Synth(\snow);
		0.4.wait;
		Synth(\snow);
		0.15.wait;
		Synth(\snow);
		x = x + 3;
		0.15.wait;
	});
	m.noteOn(0, 10, 0);
});
};
)

//--------------------------------------------




//----------------OLFATEAR---------------------
(
s = {
	(
    fork {
	    m.noteOn(0, 30, 0);
		4.do({ //olfateo rápido
			Synth(\sniff_in);
			0.15.wait;
			Synth(\sniff_out);
			0.1.wait;
		});
		Synth(\sniff_out, [dur:0.2]); //exhalacion un poco mas larga
		m.noteOn(0, 10, 0);
	}
	);
};
)
//--------------------------------------------




//---------------CORRER----------------------

// Maximum input of n = 11
(
r = { arg n = 3; var arr = [69, 72, 76, 80, 83, 87, 91, 94, 98, 102, 105];
	(
		y = Array.new(n);

		n.do{ arg i;
			i.postln();
			y.insert(i, arr.at(i));
		};
		y.postln();
		fork {
			Pbind(
				\freq, Pseq(y.midicps), //n notas incrementales
				\dur, 0.5,
				\releaseTime, 1
			).play;

			n.do({ //sonido de nieve
				m.noteOn(0, 40, 0);
				0.2.wait;
				Synth(\snow);
				0.15.wait;
				Synth(\snow);
				0.15.wait();
			});
			m.noteOn(0, 10, 0);
		}
	)
};
)
//--------------------------------------------




//----------------SALTAR----------------------
(
j = {
	(
		fork { //Secuencia salto, descenso y choque contra nieve
			m.noteOn(0, 50, 0);
			y = Synth(\jump);
			0.5.wait;
			y = Synth(\down);
			0.35.wait;
			c = Synth("crash");
			m.noteOn(0, 10, 0);
		}
	)
};
)
//--------------------------------------------



// Default run

(
fork {
	w.value(6);

	7.0.wait;
	s.value();

	1.4.wait;
	r.value(3);

	2.0.wait;
	j.value();


};

)

// RUN WITH MODULAR USAGE
w.value();
s.value();
r.value();
j.value();


// MODULAR EXAMPLES
// Only walk and run have parameters
w.value(8);
s.value();
r.value(11, [69, 72, 76, 80, 83, 87, 91, 94, 98, 102, 105]);
j.value();


