ModalBar md => JCRev reverb => Chorus c => LPF low => Echo a => dac;
1 => reverb.mix;
.7 => reverb.gain;
1 => c.mix;
100 => c.modFreq;
100 => low.freq;
10::ms => a.delay;
50 => md.freq;
6 => md.preset;
500 => float delay;

Hid mouse;
mouse.openMouse(1);

spork ~ controlMouse();

while (true) {
    0.8 => md.strikePosition;
    0.5 => md.strike;
    
    delay::ms => now;
    
    0.8 => md.strikePosition;
    0.1 => md.strike;
    
    delay*2::ms => now;
}

fun void controlMouse()
{
    HidMsg msg;
    
    while (true) {
        mouse => now;
        while (mouse.recv(msg)) {
            if (msg.type == Hid.MOUSE_MOTION)
            {
                60 + (msg.axisPosition) * 940 => delay;
            }
        }
    }
}
