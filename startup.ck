// sound file
"C:/Users/brndm_000/Desktop/miniAudicle-0.2.2c/macstartup.wav" => string filename;

//Set up network discovery (taken from Ge Wang's clix-auto.ck)
//Std.getenv("NET_NAME") => string newclient;
"128.12.234.83" => string newclient;
<<<newclient>>>;
spork ~ multicast_me();


// create our OSC receiver
OscRecv recv;
//We use port 5503 for messages to chuck, port 5502 for messages to Processing
5503 => recv.port;
recv.listen();

// create an address in the receiver, store in new variable
recv.event( "/sound/startup, f" ) @=> OscEvent @ oe;

// time loop
while( true )
{    
    // wait for event to arrive
    oe => now;
    
    // grab the next message from the queue. 
    while( oe.nextMsg() )
    { 
        oe.getFloat() => float X; 
        spork ~ startup(X);
    }
}


fun void startup(float rate)
{
    // the patch 
    SndBuf buf => dac;
    // load the file
    filename => buf.read;
    0 => buf.pos;
    rate => buf.rate;
    .5 => buf.gain;
    3::second => now;    
}


/* ******************************************************
 *                Network Discovery Code                *
 ********************************************************/
 
 //multicasts name of this machine to all on LAN (thanks to Ge Wang)
fun void multicast_me()
{
	
	// send object
	OscSend xmit;

	//multicast IP, port should also be the
	//same as the multicast recv port in the server script
	xmit.setHost( "10.30.16.150", 5501 );
		
	//send out our presence every second
	while(true)
	{

		1::second => now;

		xmit.startMsg( "/slork/newclient", "s");
		newclient => xmit.addString;
		
	}

}
 
