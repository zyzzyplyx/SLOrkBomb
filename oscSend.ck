// launch with OSC_recv.ck

// host name and port
"localhost" => string hostname;
33333 => int port;

// get command line
if( me.args() ) me.arg(0) => hostname;
if( me.args() > 1 ) me.arg(1) => Std.atoi => port;

// send object
OscSend xmit;

// aim the transmitter
xmit.setHost( hostname, port );

// infinite time loop
while( true )
{
    // start the message...
    // the type string ',f' expects a single float argument
    xmit.startMsg( "/screen/color", "i i i" );

    // a message is kicked as soon as it is complete 
    // - type string is satisfied and bundles are closed
    Math.random2( 0, 255 ) => xmit.addInt;
    Math.random2( 0, 255 ) => xmit.addInt;
    Math.random2( 0, 255 ) => xmit.addInt;
    
    xmit.startMsg("/sound/startup","f");
    Math.random2f( 0.8, 1.2) => xmit.addFloat;

    // advance time
    2::second => now;
}