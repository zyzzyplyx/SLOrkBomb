0 => int device;

// modulator to carrier
SinOsc m => SinOsc c => Envelope e => dac;

// carrier frequency
220 => c.freq;
// modulator frequency
550 => m.freq;
// index of modulation
1000 => m.gain;

// phase modulation is FM synthesis (sync is 2)
2 => c.sync;

// attack
10::ms => e.duration;
.5 => e.gain;
// variables
int base;
float v0;
float d1;
float v2;
int count;

// start things
e.keyOn();

// hid objects
Hid hi;
HidMsg msg;

// try
if( !hi.openJoystick( device ) ) me.exit();
<<< "joystick '" + hi.name() + "' ready...", "" >>>;

// infinite time loop
while( true )
{
    // wait on event
    hi => now;
    // loop over messages
    while( hi.recv( msg ) )
    {
        if( msg.isAxisMotion() )
        {
            <<<msg.which>>>;
            if( msg.which == 0 ) getV(msg.axisPosition, v0) => v0;
            else if( msg.which == 1 ) msg.axisPosition => d1;
            //else if( msg.which == 2 ) getV(msg.axisPosition, v2) => v2;
            set( v0, d1 );
        }
    }
}

fun float getV(float newP, float oldP){
    return newP - oldP;
}

// mapping function
fun void set(float v0, float v1 )
{
    
}