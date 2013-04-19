0 => int muted;

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

Hid keyboard;
keyboard.openKeyboard(0);
Hid mouse;
mouse.openMouse(0);

15 => int baseFreq;
125 => int baseTime;

[ 0, 2, 4, 7, 9, 11 ] @=> int hi[];

// Spawn threads to handle keyboard/mouse inputs
spork ~ processKeyboard(keyboard);
spork ~ processMouse(mouse);

while (true) {
    baseTime::ms => now;
    
    Std.mtof( baseFreq + Math.random2(0,3) * 12 + hi[Math.random2(0,hi.size()-1)] ) => s.freq;
    Math.random2(1, 5) => s.harmonics;
}

fun void processMouse(Hid mouse)
{
    HidMsg msg;
    
    while (true) {
        mouse => now;
        
        while (mouse.recv(msg)) {
            if (msg.type == Hid.MOUSE_MOTION)
            {
                // Volume control with mouse
                if (msg.deltaX > 0) {
                    gain + 0.005 => gain;
                    gain => s.gain;
                }
                else if (msg.deltaX < 0)
                {
                    if (gain - 0.005 > 0) {
                        gain - 0.005 => gain;
                        gain => s.gain;
                    }
                }
            }
        }
    }
}

fun void processKeyboard(Hid keyboard)
{
    HidMsg msg;
    
    while (true) {
        keyboard => now;
        
        while (keyboard.recv(msg)) {
            if (msg.type == Hid.BUTTON_DOWN)
            {
                // R key for getting random freq
                if (msg.ascii == 82) {
                    Math.random2(1, 80) => baseFreq;
                }
                
                // W key for increasing depth
                if (msg.ascii == 87) {
                    if (mDepth + 0.05 > 0) {
                        mDepth + 0.05 => mDepth;
                        mDepth => r.modDepth;
                    }
                }
                
                // S key for decreasing depth
                if (msg.ascii == 83) {
                    if (mDepth - 0.05 > 0) {
                        mDepth - 0.05 => mDepth;
                        mDepth => r.modDepth;
                    }
                }
                
                // A key for slowing down
                if (msg.ascii == 65) {
                    baseTime + 10 => baseTime;
                }
                
                // D key for speeding up
                if (msg.ascii == 68) {
                    if (baseTime - 10 > 0) {
                        baseTime - 10 => baseTime;
                    }
                }
                
                // Q key to toggle mute
                if (msg.ascii == 81) {
                    if (muted == 0) {
                        0 => s.gain;
                        1 => muted;
                    }
                    else {
                        gain => s.gain;
                    }
                }
                
                // E key for noise
                if (msg.ascii == 69) {
                    spork ~ noise();
                }
                
                <<< msg.ascii >>>;
            }
        }
    }
}

fun void noise()
{
    Noise n => LPF l => NRev r => dac;

    Math.random2(50, 200) => int init;
    init => l.freq;
    Math.random2(2, 25) => int t;
    Math.random2(100, 500) => int d;

    Math.random2(0, 1) => int inc;
    
    if (inc == 1) {
        for (init + 1 => int i; i <= init + d; i++)
        {
            i => l.freq;
            t::ms => now;
        }
    }
    else {
        for (init + d => int i; i >= init + 1; i--)
        {
            i => l.freq;
            t::ms => now;
        }
    }
}