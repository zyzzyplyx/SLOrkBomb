1024 => int num_chars;

Hid keyboard;
keyboard.openKeyboard(0);
//[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> 
int data[num_chars];

// setup our audios - frequency modulation (FM)
//SqrOsc mod => SinOsc car => Envelope env => NRev reverb => dac;
//0.05 => reverb.mix;
SqrOsc mod => SinOsc car => Envelope env => dac;
// this is the magic that tells chuck to do FM
//2 => car.sync;

.01 => dac.gain;

1000 => mod.gain;
//10 => mod.freq;
800000000 => car.freq;
//1 => car.gain;

spork ~ pulsate();
spork ~ processKeyboard(keyboard);

1 => env.keyOn;
0 => int count;
while(true)
{
    
    data[count] => int c;
    while (c != 0)
    {
        (c & 1)*1000 => mod.gain;
        1::ms => now;
        1000 => mod.gain;
        1::ms => now;
        c / 2 => c; //bitshift right (hack)
    }
    
    (count + 1)%num_chars => count;    
            
    1::ms => now;
}
1 => env.keyOff;

fun void pulsate()
{
    while(true)
    {
        1 => car.gain;
        5::ms => now;
        8 => car.gain;
        5::ms => now;
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
                }
                else
                {
                    msg.ascii => data[count];
                    (count + 1)%num_chars => count;
                }
            }
        }
    }
}