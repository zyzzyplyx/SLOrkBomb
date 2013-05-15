// Global variables
float v0;
float d1;
0 => int sent;

// For server operations
50 => int maxclients; 		//when SLOrk gets really huge, we can change this!
string clients[maxclients];	//for storing client names, as needed
0 => int numclients;		//number of current clients
OscSend screens[maxclients];	//osc connection to Processing clients
OscSend sounds[maxclients];     //osc connections to Chuck clients
5502 => int screen; 			//port for sockets to Processing clients
5503 => int sound;              //port for sockets to Chuck clients
spork ~ multicast_receive();

// hid objects
Hid hi;
HidMsg msg;

OpenHID();

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
            //<<<msg.which>>>;
            if( msg.which == 0 ) getV(msg.axisPosition, v0) => v0;
            else if( msg.which == 1 ) msg.axisPosition => d1;
            //else if( msg.which == 2 ) getV(msg.axisPosition, v2) => v2;
            set( v0, d1 );
        }
    }
}


/* ******************************************************
 *                    Initialization                    *
 *******************************************************/
 fun void OpenHID(){
     // try
    if( !hi.openJoystick( 0 ) ) me.exit();
    <<< "joystick '" + hi.name() + "' ready...", "" >>>;
 }

/* ******************************************************
 *                      Helpers                         *
 *******************************************************/
fun float getV(float newP, float oldP){
    return newP - oldP;
}

/* ******************************************************
 *                Target Acquisition Code               *
 ********************************************************/
 // listens for multicast messages from clients
 // Thanks to Ge Wang for this implementation
fun void multicast_receive()
{
    <<<"waiting">>>;
    // create our OSC receiver
    OscRecv recv;
    5501 => recv.port;
    // start listening (launch thread)
    recv.listen();

    // create an address in the receiver, store in new variable
    recv.event( "/slork/newclient, s" ) @=> OscEvent oe;

    // infinite event loop
    while ( true )
    {
        // wait for event to arrive
        oe => now;

        // grab the next message from the queue. 
        while( oe.nextMsg() != 0 )
        {
            oe.getString() 	=> string newClientName;
            newsocket(newClientName);
        }
    }
}

//check to see if hosttoadd is already
//connected and if not, open up socket
// Thanks to Ge Wang for this implementation
fun void newsocket(string hosttoadd)
{

	0 => int gotAlready;

	for(0=>int j;j<numclients;j++) {
		if (hosttoadd == clients[j]) {
			1 => gotAlready;
		}
	}
	
	if(!gotAlready) {
	
		hosttoadd => clients[numclients];  //retain client names if needed
		hosttoadd + ".local" => hosttoadd;
		<<<"adding " + hosttoadd + " as client # " + numclients>>>;

		screens[numclients].setHost( hosttoadd, screen );
        sounds[numclients].setHost( hosttoadd, sound );
		
		numclients++;
		
	}
		
}
 
 /* ******************************************************
  *                Message Dispatching Code              *
  ********************************************************/
  
  fun void set(float v0, float d1 )
{
    if(v0 > 0 && sent == 0){
        ((d1 + 1) / 2 * numclients) $ int => int target;
        
        //Dispatch message to processing
        screens[target].startMsg("/screen/color", "i i i");
        Math.random2( 0, 255 ) => screens[target].addInt;
        Math.random2( 0, 255 ) => screens[target].addInt;
        Math.random2( 0, 255 ) => screens[target].addInt;
        
        //Then cue sound
        sounds[target].startMsg("/sound/startup", "f");
        Math.random2f( 0.8, 1.2) => sounds[target].addFloat;
            
        //TODO: Advance time?
        
        1 => sent;   
    }
    else if(v0 < -.1) 0 => sent;       
}