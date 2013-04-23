// DO FM SYNTH!!!
// setup our audios - frequency modulation (FM)
SinOsc modr => SinOsc car => Envelope env => NRev reverb => dac;
SinOsc modl => car;
0.05 => reverb.mix;
// this is the magic that tells chuck to do FM
2 => car.sync;
.02 => dac.gain;

// set carrier frequency
200 => car.freq;

// create our OSC receiver
OscRecv recv;
// use port 6449 (or whatever)
12345 => recv.port;
// start listening (launch thread)
recv.listen();

// create an address in the receiver, store in new variable
recv.event( "/right/x, f" ) @=> OscEvent @ oerx;
recv.event( "/right/y, f" ) @=> OscEvent @ oery;
recv.event( "/left/x, f" ) @=> OscEvent @ oelx;
recv.event( "/left/y, f" ) @=> OscEvent @ oely;

spork ~ ControlPitch(oerx, modr, 200);
//spork ~ ControlPitch(oelx, modl, 400);
spork ~ ControlGain(oery, modr);
//spork ~ ControlGain(oely, modl);
0 => modr.gain;
spork ~ ControlBeats(oely, modr, modl);

//spork ~ ControlRhythm(oelx, env);

1 => env.keyOn;

1::day => now;

fun void ControlBeats (OscEvent oe, SinOsc base, SinOsc beat)
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
            base.freq() + Math.max(20*X, 0) => beat.freq;
            base.gain() => beat.gain;
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

fun void ControlPitch (OscEvent oe, SinOsc s, int center)
{
    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oe => now;
        
        // grab the next message from the queue. 
        while( oe.nextMsg() )
        { 
            float X;
            
            // getFloat fetches the expected float (as indicated by "i f")
            oe.getFloat() => X;
            Math.pow(2, X)*center => float freq;
            freq => s.freq;
            
            // print
            //<<< "PITCH:", freq >>>;
        }
    }
}

fun void ControlRhythm (OscEvent oe, Envelope env)
{
    // infinite event loop
    0 => int count;
    while( true )
    {
        // wait for event to arrive
        oe => now;
        while(oe.nextMsg())
        {
            // getFloat fetches the expected float (as indicated by "i f")
            oe.getFloat() => float X;
            
            if(count == 30)
            {
                0 => count;
                spork ~ twiddle(((X+1)/4), 1, env);
            }
            else
            {
                count + 1 => count;
            }
        }
    }
}

// Runs for duration seconds, turning env on at frequency freq
fun void twiddle(float freq, float duration, Envelope env)
{
    0.0 => float elapsed;
    while(elapsed < duration)
    {
        1 => env.keyOn;
        (freq * 500)::ms => now;
        1 => env.keyOff;
        (freq * 500)::ms => now;
        elapsed + freq => elapsed;
    }
}
