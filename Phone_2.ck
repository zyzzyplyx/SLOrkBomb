128 => int num_chars; //Default: 128, tunable
3.6 => float duty;
1 => float dac_gain;
0 => int char_count;

[1.5, 32, 9, 8, 7, 6, 5, 4, 3, 2.5] @=> float tones[];

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
    //logic is inverted here.  Alive == 0 means continue to loop,
    // alive will be set to char count when it is time to exit.
    while(alive == 0)
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
    
    env.gain() => float old_gain;
    <<< alive >>>;
    .15::second => dur off_time;
    if(alive > 10){
        <<< "BOOM" >>>;
        20 => env.gain;
        1::second => off_time;
    }
        
    off_time=> env.duration;
    1 => env.keyOff;
    off_time => now;
    old_gain => env.gain;
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
    while (true) {
        keyboard => now;
        
        while (keyboard.recv(msg)) {        
            if (msg.type == Hid.BUTTON_DOWN)
            {
                if(msg.ascii == 32)
                {
                    for(0 => int i; i < num_chars; i ++)
                        0 => data[i];
                    char_count => alive;
                    0 => char_count;
                } 
                else if(msg.ascii >= 48 && msg.ascii < 58)
                {
                    //if(((duty == tones[0]) && (msg.ascii == 48)) || 
                    //   ((duty == tones[1]) && (msg.ascii == 49)))
                    //   duty / 2 => duty;
                    tones[msg.ascii - 48] => duty;
                    
                }
                else
                {
                    if(alive != 0)
                    {
                        1 => env.keyOn;
                        0 => alive;
                        spork ~ blip();
                    }
                    msg.ascii => data[Math.random2(0,num_chars - 1)];
                    1 + char_count => char_count;
                    //Maybe also use this to change speed?
                    //msg.ascii => data[count];
                    //(count + 1)%128 => count;
                }
            }
        }
    }
}
