0 => int muted;

BlitSquare s => LPF l => Chorus r => NRev rev => dac;

0.02 => float gain;
0.1 => float mix;
200 => float mFreq;
1 => float mDepth;
1000 => float lFreq;

//Randomization control
0 => int cycle;
true => int randomize;
12 => int numNotes;
int offset[numNotes];
int index[numNotes];

gain => s.gain;
mix => r.mix;
mFreq => r.modFreq;
mDepth => r.modDepth;
lFreq => l.freq;
0.5 => rev.mix;
0.4 => dac.gain;

//Spawn keyboard listener
Hid keyboard;
keyboard.openKeyboard(0);

// create our OSC receiver
OscRecv recv;
// use port 6449 (or whatever)
12345 => recv.port;
// start listening (launch thread)
recv.listen();

// create an address in the receiver, store in new variable
recv.event( "/right/x, f" ) @=> OscEvent @ oerx;
recv.event( "/right/y, f" ) @=> OscEvent @ oery;
recv.event( "/right/z, f" ) @=> OscEvent @ oerz;
recv.event( "/left/x, f" ) @=> OscEvent @ oelx;
recv.event( "/left/y, f" ) @=> OscEvent @ oely;
recv.event( "/left/z, f" ) @=> OscEvent @ oelz;

15 => float baseFreq;
125 => float baseTime;

[ 0, 2, 4, 7, 9, 11 ] @=> int hi[];

// Spawn Kinect Controls
spork ~ speedControl (oelx, 125);
spork ~ depthControl (oely);
spork ~ gainControl (oery, .125);
spork ~ randomizeFreq (oerx);

Noise n => LPF lo => NRev reverb => dac;
spork ~ noise(lo);
spork ~ makeNoise (oelz, lo);

//Still using keyboard for mute (for now)
spork ~ processKeyboard(keyboard);

while (true) {
    baseTime::ms => now;
    if(randomize)
    {
        Math.random2(0,3) * 12 => offset[cycle];
        Math.random2(0,hi.size()-1) => index[cycle];
    }
    Std.mtof( baseFreq + offset[cycle] + hi[index[cycle]] ) => s.freq;
    Math.random2(1, 5) => s.harmonics;
    1 +=> cycle;
    if(cycle == numNotes)
    {
        0 => cycle;
    }
}

/* sporks a noise whenever OscEvent crosses a threshold */
fun void makeNoise (OscEvent oe, LPF l)
{
    while( true )
    {
        oe => now;
        
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            Math.max((X)/8, 0) => l.gain;
        }
    } 
}

/* Controls gain for the sin oscillator, using an oe event
Expects signal to be on the range [-1, 1]
*/
fun void gainControl (OscEvent oe, float centerGain)
{
    while( true )
    {
        oe => now;
        
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            Math.max(centerGain + X/4, 0) => s.gain;
        }
    } 
}

/* Modifies the baseTime parameter using whatever event is passed.
Expects event to be on range [-1, 1]
*/
fun void speedControl (OscEvent oe, float centerTime)
{
    while( true )
    {
        oe => now;
        
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            centerTime + 100*X => baseTime;
        }
    } 
}

/* Controls mod depth using an osc event */
fun void depthControl (OscEvent oe)
{
    while( true )
    {
        oe => now;
        
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            X + 1 => r.modDepth;
        }
    } 
}

fun void randomizeFreq (OscEvent oe)
{
    while( true )
    {
        oe => now;
        
        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            if( X > .5)
            {
                true => randomize;
                Math.random2(1, 80) => baseFreq;
            }
            else
                true => randomize;
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
                // Space bar to toggle mute
                if (msg.ascii == 32) {
                    if (muted == 0) {
                        0 => s.gain;
                        1 => muted;
                    }
                    else {
                        gain => s.gain;
                    }
                }
            }
        }
    }
}

fun void noise(LPF l)
{   
    Math.random2(50, 200) => int init;
    init => l.freq;
    0 => l.gain;
    
    while (true)
    {
        Math.random2(2, 5) => int t;
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
        1::ms => now;
    }
}

