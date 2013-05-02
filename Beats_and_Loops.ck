Hid keyboard;
keyboard.openKeyboard(0);

/* ~~~~~~~~~~~~~~ KEYBOARD INSTRUMENT ~~~~~~~~~~~~~~ */
16 => int numNotes;
0 => int muted;
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int notes[];
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int loop[];

//BlitSquare s => LPF l => Chorus r => dac;
//BlitSquare s => dac;
SawOsc s => Envelope e => NRev rev => dac;
0.01 => float gain;

0 => s.gain;
0.05 => rev.mix;

150 => int baseTime;

// Spawn threads to handle keyboard/mouse inputs
spork ~ processKeyboard(keyboard);

while (true) {
    0 => int i;
    while(i < numNotes)
    {
        e.keyOn();
        baseTime::ms => now;
        if(loop[i] == 0)
            0 => s.gain;
        else
        {
            Std.mtof( loop[i]*i/2 + 50 ) => s.freq;
            gain => s.gain;
        }   
        1 +=> i;
        e.keyOff();
    }
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
