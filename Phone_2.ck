128 => int num_chars; //Default: 128, tunable
3.6 => float duty;
1 => float dac_gain;

[1.0, 32, 9, 8, 7, 6, 5, 4, 3, 2] @=> float tones[];

Envelope env => dac;
dac_gain => dac.gain;

Hid keyboard;
keyboard.openKeyboard(0);
int data[num_chars];

1 => int alive;
spork ~ blip();
spork ~ pulsate();
spork ~ processKeyboard(keyboard);

1::day => now;

fun void blip()
{
    // setup our audios - frequency modulation (FM)
    //SqrOsc mod => Envelope e2 => SinOsc car => Envelope env => NRev reverb => dac;
    //0.05 => reverb.mix;
    SawOsc mod => Envelope e2 => SinOsc car => env;
    .5::ms => e2.duration;
    .5::second => env.duration;
    
    //duty * (40.0 + Math.random2(0,20))/50 => duty;
    
    // this is the magic that tells chuck to do FM
    //1 => car.sync;

    1000 => mod.gain;
    1000 => mod.freq; //Default: 300, tunable, makes sound poppier
    800000000 => car.freq;
    //1 => car.gain;
    
    1 => env.keyOn;
    
    0 => int count;
    while(alive)
    {
        data[count] => int c;
        while(c != 0)
        {
            c & 1 => e2.keyOn;
            .1::ms => now;
            c & 1 => e2.keyOff;
            .1::ms => now;
            c / 2 => c; //bitshift right (hack)
        }
        1::ms => now; //Default: 1.25, tunable, controls beat speed
        (count + 1)%num_chars => count;
    }
    
    // One long pulse at end
    //3 => dac_gain;
    //300::ms => now;
    //1 => dac_gain;
    
    1 => env.keyOff;
}

fun void pulsate()
{
    while(true)
    {
        dac_gain => dac.gain;
        //1 => env.keyOn;
        1::ms => now;
        0 => dac.gain;
        //1 => env.keyOff;
        duty::ms => now;
    }
}

fun void processKeyboard(Hid keyboard)
{
    HidMsg msg;
    0 => int count;
    while (true) {
        keyboard => now;
        
        while (keyboard.recv(msg)) {        
            if (msg.type == Hid.BUTTON_DOWN)
            {
                if(msg.ascii == 32)
                {
                    for(0 => int i; i < num_chars; i ++)
                        0 => data[i];
                    0 => alive;
                } 
                else if(msg.ascii >= 48 && msg.ascii < 58)
                {
                    tones[msg.ascii - 48] => duty;
                }
                else
                {
                    if(!alive)
                    {
                        1 => env.keyOn;
                        1 => alive;
                        spork ~ blip();
                    }
                    msg.ascii => data[Math.random2(0,num_chars - 1)];
                    //Maybe also use this to change speed?
                    //msg.ascii => data[count];
                    //(count + 1)%128 => count;
                }
            }
        }
    }
}
