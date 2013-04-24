/* ~~~~~~~~~~~~~FM BEATS INSTRUMENT SETUP ~~~~~~~~~~~~~~~~~~~ */

// setup our audios - frequency modulation (FM)
SinOsc modr => SinOsc car => Envelope env => NRev reverb => LPF low => dac;
SinOsc modl => car;
0.05 => reverb.mix;
// this is the magic that tells chuck to do FM
2 => car.sync;
.5 => dac.gain;
300 => modr.gain;
300 => modl.gain;
100 => low.freq;
.01 => low.gain;

// set carrier frequency
100 => car.freq;

Hid keyboard;
keyboard.openKeyboard(0);
Hid mouse;
mouse.openMouse(1);

spork ~ ControlBeats(modr, modl);

1 => env.keyOn;

/* ~~~~~~~~~~~~~~ KEYBOARD INSTRUMENT ~~~~~~~~~~~~~~ */

0 => int muted;
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int notes[];
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int loop[];

BlitSquare s => LPF l => Chorus r => dac;

0.02 => float gain;
0.1 => float mix;
200 => float mFreq;
1 => float mDepth;
1000 => float lFreq;

gain => s.gain;
mix => r.mix;
mFreq => r.modFreq;
mDepth => r.modDepth;
lFreq => l.freq;

15 => int baseFreq;
125 => int baseTime;

// Spawn threads to handle keyboard/mouse inputs
spork ~ processKeyboard(keyboard);

while (true) {
    0 => int i;
    while(i < 16)
    {
        baseTime::ms => now;
        Std.mtof( loop[i] + 60 ) => s.freq;
        1 +=> i;
    }
    Math.random2(1, 5) => s.harmonics;
    1::ms => now;
}

fun void processKeyboard(Hid keyboard)
{
    HidMsg msg;
    
    while (true) {
        keyboard => now;
        
        while (keyboard.recv(msg)) {
            if (msg.type == Hid.BUTTON_DOWN)
            {
                if(msg.ascii == 10)
                {
                    <<< "inserting" >>>;
                    // Set the current beat pattern to the performance
                    notes @=> loop;
                    [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> notes;
                }
                else
                {
                    msg.ascii % 16 => int index;
                    1 +=> notes[index];
                }
                
                <<< msg.ascii >>>;
            }
        }
    }
}

fun void ControlBeats (SinOsc base, SinOsc beat)
{   
    HidMsg msg;
    
    while (true) {
        mouse => now;
        
        while (mouse.recv(msg)) {
            if (msg.type == Hid.MOUSE_MOTION)
            {
                msg.axisPosition => float X; 
              base.freq() + Math.max(20*X, 0) => beat.freq;
              //base.gain() => beat.gain;
              
              Math.pow(2, X+1)*car.freq() => float freq;
              freq => modr.freq;
                
                car.freq() + msg.deltaY/10 => car.freq;

            }
        }
    }
}

fun void ControlGain (OscEvent oe, SinOsc s)
{
    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oe => now;
        
        // grab the next message from the queue. 
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;            
            //Math.min(Math.max(X, 0)*1.5, .2) => s.gain;
            300 * (X + 1) => s.gain;
            // print
            //<<< "GAIN:", X >>>;
        }
    }
}
