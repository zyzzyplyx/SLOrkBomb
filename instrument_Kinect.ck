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

15 => int baseFreq;
125 => int baseTime;

[ 0, 2, 4, 7, 9, 11 ] @=> int hi[];

// Spawn Kinect Controls
spork ~ speedControl (oelx, 125);
spork ~ depthControl (oely);
spork ~ gainControl (oery, .25);
spork ~ randomizeFreq (oerx);

//Still using keyboard for mute (for now)
spork ~ processKeyboard(keyboard);

while (true) {
    baseTime::ms => now;
    
    Std.mtof( baseFreq + Math.random2(0,3) * 12 + hi[Math.random2(0,hi.size()-1)] ) => s.freq;
    Math.random2(1, 5) => s.harmonics;
}

fun void makeNoise (OscEvent oe)
{
    while( true )
    {
        oe => now;

        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            if( X < 1)
                spork ~ noise();
        }
    } 
}

/* Controls gain for the sin oscillator, using an oe event
   Expects signal to be on the range [-1, 1]
   */
fun void gainControl (OscEvent oe, centerGain)
{
    while( true )
    {
        oe => now;

        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            centerGain + X/2 => s.gain;
        }
    } 
}

/* Modifies the baseTime parameter using whatever event is passed.
   Expects event to be on range [-1, 1]
   */
fun void speedControl (OscEvent oe, centerTime)
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
fun void depthControl (OscEvent oe, centerDepth)
{
    while( true )
    {
        oe => now;

        while( oe.nextMsg() )
        { 
            oe.getFloat() => float X;             
            X => r.modDepth;
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
               Math.random2(1, 80) => baseFreq;
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