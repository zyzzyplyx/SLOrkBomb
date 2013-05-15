// sound file
"C:/Users/brndm_000/Desktop/miniAudicle-0.2.2c/macstartup.wav" => string filename;



// time loop
while( true )
{    
    if(Math.random2(1, 5) > 1)
        startup();
    
    50::ms => now;
}

fun void startup()
{
    // the patch 
    SndBuf buf => dac;
    // load the file
    filename => buf.read;
    0 => buf.pos;
    Math.random2(0,5)/5.0 + .8 => buf.rate;
    .5 => buf.gain;
    1::second => now;    
}