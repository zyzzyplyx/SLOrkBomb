Hid keyboard;
keyboard.openKeyboard(0);
Hid mouse;
mouse.openMouse(1);

//uncomment this to turn off the bass
//low =< dac;

/* ~~~~~~~~~~~~~~ KEYBOARD INSTRUMENT ~~~~~~~~~~~~~~ */
16 => int numNotes;
0 => int muted;
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int notes[];
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int loop[];

//BlitSquare s => LPF l => Chorus r => dac;
BlitSquare s => dac;
0.03 => float gain;
0.1 => float mix;
200 => float mFreq;
.5 => float mDepth;
1000 => float lFreq;

0 => s.gain;
//mix => r.mix;
//mFreq => r.modFreq;
//mDepth => r.modDepth;
//lFreq => l.freq;

15 => int baseFreq;
125 => int baseTime;

// Spawn threads to handle keyboard/mouse inputs
spork ~ processKeyboard(keyboard);

while (true) {
    0 => int i;
    while(i < numNotes)
    {
        baseTime::ms => now;
        if(loop[i] == 0)
            0 => s.gain;
        else
        {
            Std.mtof( loop[i]*i/2 + 60 ) => s.freq;
            gain => s.gain;
        }   
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
                    msg.ascii % numNotes => int index;
                    1 +=> notes[index];
                }
                
                <<< msg.ascii >>>;
            }
        }
    }
}
