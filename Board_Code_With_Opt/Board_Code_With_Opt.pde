#include <WiFiShieldOrPmodWiFi.h>
#include <DNETcK.h>
#include <DWIFIcK.h>
#include <pt.h>



//--------------------------------------------------------------------------------//
//------------------------------WiFi Configuration--------------------------------//
//--------------------------------------------------------------------------------//

IPv4 ipServer = {169,254,1,0};
//use port 44400
unsigned short portServer = DNETcK::iPersonalPorts44 + 400;

//SSID
const char * szSsid = "BugWiFi";

// select 1 for the security you want, or none for no security
//#define USE_WPA2_PASSPHRASE
//#define USE_WPA2_KEY

// modify the security key to what you have.
#if defined(USE_WPA2_PASSPHRASE)

    const char * szPassPhrase = "BugWiFi";
    #define WiFiConnectMacro() DWIFIcK::connect(szSsid, szPassPhrase, &status)

#elif defined(USE_WPA2_KEY)

    DWIFIcK::WPA2KEY key = { 0x27, 0x2C, 0x89, 0xCC, 0xE9, 0x56, 0x31, 0x1E, 
                            0x3B, 0xAD, 0x79, 0xF7, 0x1D, 0xC4, 0xB9, 0x05, 
                            0x7A, 0x34, 0x4C, 0x3E, 0xB5, 0xFA, 0x38, 0xC2, 
                            0x0F, 0x0A, 0xB0, 0x90, 0xDC, 0x62, 0xAD, 0x58 };
    #define WiFiConnectMacro() DWIFIcK::connect(szSsid, key, &status)

#else   // no security - OPEN

    #define WiFiConnectMacro() DWIFIcK::connect(szSsid, &status)

#endif
//--------------------------------------------------------------------------------//
//----------------------------End of WiFi Configuration---------------------------//
//--------------------------------------------------------------------------------//



//--------------------------------------------------------------------------------//
//-----------------------------WiFi Data Configuration----------------------------//
//--------------------------------------------------------------------------------//
typedef enum
{
    NONE = 0,
    INITIALIZE,
    LISTEN,
    ISLISTENING,
    AVAILABLECLIENT,
    ACCEPTCLIENT,
    READ,
    WRITE,
    CLOSE,
    EXIT,
    DONE
} STATE;

STATE state = INITIALIZE;

unsigned tStart = 0;
unsigned tWait = 5000;

TcpServer tcpServer;
TcpClient tcpClient;

//initialize all of the buffers and counters that are going to be used
byte rgbRead[512];
byte ReadQueue[512];
byte rgbWrite[512];
char buffer[512];
int cbRead = 0;
int count = 0;

DNETcK::STATUS status;
//--------------------------------------------------------------------------------//
//-------------------------End of WiFi data Configuration-------------------------//
//--------------------------------------------------------------------------------//



//--------------------------------------------------------------------------------//
//-----------------------------BUG data Configuration-----------------------------//
//--------------------------------------------------------------------------------//
static struct pt pt1, pt2,pt3;

int PWMvalue = 180;
int OEvalue = 0;
int RELAYvalue = 0;
int DIRvalue = 0;
int steps = 0;

//JA - Upper Bank
//use for analog input of potentiometer
const int PM = 0;

//use as a voltage reference for potentiometer
const int PMVR = 1;

//JA - Lower Bank
//use for relay or drive motor enable
const int RELAY = 4;

//use for output enable of stepper motor
const int OE = 5; 

//use for direction of stepper motor
const int DIR = 6;

//JD - Lower Bank
//use for PWM of drive motor
const int PWM1 = 28;  

//use for clock of stepper motor
const int CLOCK = 29; 

//ise for LED to know the status of the board 
const int LED1 = 51;
const int LED2 = 52;
const int LED3 = 53;
const int LED4 = 54; 

//pin used for read optical sensor value
const int OPTICAL = 2;

//value read from the optical sensor
boolean OPT_VAL = false;

//pin used for optical sensor's testing LED
const int OPT_LED = 3;

//----------------------------------------------------------------------------------//
//---------------------------End of BUG data Configuration--------------------------//
//----------------------------------------------------------------------------------//

//turn external LED on and off according to the optical sensor value
void externalLED(boolean state){
	if(state){
		digitalWrite(OPT_LED,LOW);
	}else{
		digitalWrite(OPT_LED,HIGH);
	}	
}

void setup(){
    //initialize the two threads needed for communication and running BUG
    PT_INIT(&pt1);
    PT_INIT(&pt2);
    
    //setup all of the ports that is going to be used either as input or output
    pinMode(RELAY,OUTPUT);
    pinMode(PWM1,OUTPUT);
    pinMode(OE,OUTPUT);
    pinMode(DIR,OUTPUT);
    pinMode(CLOCK,OUTPUT);
    pinMode(PMVR,OUTPUT);
    pinMode(PM, INPUT);
    pinMode(LED1,OUTPUT);
    pinMode(LED2,OUTPUT);
    pinMode(LED3,OUTPUT);
    pinMode(LED4,OUTPUT);
	pinMode(OPTICAL,INPUT);
	pinMode(OPT_LED,OUTPUT);
    
    //initialize the value for RELAY, OE, PMVR and PWM1
    //so that BUG does not move
    digitalWrite(RELAY, HIGH);
    digitalWrite(OE, HIGH);
    digitalWrite(PMVR, HIGH);
    analogWrite(PWM1, PWMvalue);
  
    for(int i = 0; i < 512; i++){
        ReadQueue[i] = 0;
    }
    
    //Read the value of potentiometer and use it to center the motor
    steps = analogRead(PM);
    if(steps < 663){
        while(steps < 663){
            digitalWrite(DIR, LOW);
            analogWrite(CLOCK, 127);
            steps = analogRead(PM);
        }
    }else if(steps > 663){
        while(steps > 663){
            digitalWrite(DIR, HIGH);
            analogWrite(CLOCK, 127);
            steps = analogRead(PM);
        }
    }
    analogWrite(CLOCK, 0);
    
	//read the optical sensor value and change the LED state
	OPT_VAL=digitalRead(OPTICAL);
	externalLED(OPT_VAL);
	
    //setup the Wi-Fi for the BUG
    int conID = DWIFIcK::INVALID_CONNECTION_ID;
    lightLED(1,0,0,0);
    if((conID = WiFiConnectMacro()) != DWIFIcK::INVALID_CONNECTION_ID){
        lightLED(0,1,0,0);
        state = INITIALIZE;
    }else{
        lightLED(1,1,0,0);
        state = EXIT;
    }
  
    // intialize the stack with a static IP
    DNETcK::begin(ipServer);
    Serial.begin(9600); //added
}

void loop(){
    //start running the two threads that will handle the communication and running BUG
    protothread1(&pt1, 100);
    protothread2(&pt2, 100);
    protothread3(&pt3, 100);
} 



//runBUG - function
//takes a buffer as an input
//decode the buffer value to know what is the value of OE, DIR, RELAY and PWM respectively
void runBUG(byte rgbRead[]){
    //command format [], [],  [],    [],[],[]
    //               OE, DIR, RELAY, PWM
    OEvalue = int(char(rgbRead[0]) - 48);
    DIRvalue = int(char(rgbRead[1]) - 48);
    RELAYvalue = int(char(rgbRead[2]) - 48);
    PWMvalue = int(char(rgbRead[3]) - 48)*100 + int(char(rgbRead[4]) - 48)*10 + int(char(rgbRead[5]) - 48);       
    
    if((RELAYvalue == 1) && (PWMvalue < 120)){
        digitalWrite(RELAY, LOW);
        analogWrite(PWM1, 120);
    }else if((RELAYvalue == 1) && (PWMvalue > 227)){
        digitalWrite(RELAY, LOW);
        analogWrite(PWM1, 227);
    }else if((RELAYvalue == 1) && (120 < PWMvalue < 227)){
        digitalWrite(RELAY,LOW);
        analogWrite(PWM1, PWMvalue);    
    }else{
        digitalWrite(RELAY, HIGH);
        analogWrite(PWM1, PWMvalue);
    }
    digitalWrite(OE, HIGH);   //taken out
    steps = analogRead(PM);
    if((steps > 230) && (DIRvalue == 1) && (OEvalue == 1)){  //turn left
        //enable the stepper motor
        digitalWrite(OE, HIGH);//added
        digitalWrite(DIR, HIGH);
        analogWrite(CLOCK, 127);
        delay(10);
        steps = analogRead(PM);   
    }else if((steps < 920) && (DIRvalue == 0) && (OEvalue == 1)){  //turn right
        //enable the stepper motor
        digitalWrite(OE, HIGH);//added
        digitalWrite(DIR, LOW);
        analogWrite(CLOCK, 127);
        delay(10);
        steps = analogRead(PM);
    }else if(OE == 0){   //turn stepper motor off ##ADDED THIS TO STOP IT FROM TURNING
        digitalWrite(OE, LOW);
        steps = analogRead(PM);
    }else{
        analogWrite(CLOCK, 0);
    }
}


//lightLED - function
//takes 4 int input
//set the LED based on the value if 1 or 0
void lightLED(int valueLED1, int valueLED2, int valueLED3, int valueLED4){
    if(valueLED1 == 1){
        digitalWrite(LED1, HIGH);
    }else{
        digitalWrite(LED1, LOW);
    }
    
    if(valueLED2 == 1){
        digitalWrite(LED2, HIGH);
    }else{
        digitalWrite(LED2, LOW);
    }
    
    if(valueLED3 == 1){
        digitalWrite(LED3, HIGH);
    }else{
        digitalWrite(LED3, LOW);
    }
    
    if(valueLED4 == 1){
        digitalWrite(LED4, HIGH);
    }else{
        digitalWrite(LED4, LOW);
    }
}

//thread 1 that handles how the BUG should run, it calls the runBUG function
static int protothread1(struct pt *pt, int interval){
    static unsigned long timestamp = 0;
    PT_BEGIN(pt);
    while(1){
        PT_WAIT_UNTIL(pt, millis() - timestamp > interval);
        timestamp = millis();
        //!!!!!!!!!!!!!!!!!!!!!!!!!
        //commented out the runBUG function to see if it is causing issues in the bug.        
        //!!!!!!!!!!!!!!!!!!!!!!!!!
        runBUG(ReadQueue);
    }
    PT_END(pt);
}

//thread 2 that handles the communication of BUG
static int protothread2(struct pt *pt, int interval){
    static unsigned long timestamp = 0;
    PT_BEGIN(pt);
    while(1){
        PT_WAIT_UNTIL(pt, millis() - timestamp > interval);
        timestamp = millis();
        switch(state){
        
            case INITIALIZE:
                if(DNETcK::isInitialized(&status)){
                    lightLED(0,0,1,0);
                    state = LISTEN;
                }else if(DNETcK::isStatusAnError(status)){
                    lightLED(1,0,1,0);
                    state = EXIT;
                }
            break;
    
        
            // say to listen on the port
            case LISTEN:
                if(tcpServer.startListening(portServer)){
                    lightLED(0,1,1,0);
                    state = ISLISTENING;
                }else{
                    state = EXIT;
                }
            break;
    
    
            // not specifically needed, we could go right to AVAILABLECLIENT
            // but this is a nice way to print to the serial monitor that we are 
            // actively listening.
            // Remember, this can have non-fatal falures, so check the status
            case ISLISTENING:
                Serial.print("ISLISTENING ");
                Serial.println("");
                if(tcpServer.isListening(&status)){
                    lightLED(1,1,1,0);
                    state = AVAILABLECLIENT;
                }else if(DNETcK::isStatusAnError(status)){
                    state = EXIT;
                }
            break;
    
    
            // wait for a connection
            case AVAILABLECLIENT:
                Serial.print("AVAILABLECLIENT ");
                Serial.println("");
                if((count = tcpServer.availableClients()) > 0){
                    lightLED(0,0,0,1); 
                    state = ACCEPTCLIENT;
                }
            break;
    
    
            // accept the connection
            case ACCEPTCLIENT:   
                    Serial.print("ACCEPTCLIENT ");
                    Serial.println("");
            
                // probably unneeded, but just to make sure we have
                // tcpClient in the  "just constructed" state
                tcpClient.close(); 
                // accept the client 
                if(tcpServer.acceptClient(&tcpClient)){
                    lightLED(1,0,0,1);       
                    state = READ;
                    tStart = (unsigned) millis();
                }else{
                    state = ISLISTENING;
                }
            break;
    
    
            // wait for the read, but if too much time elapses (5 seconds)
            // we will just close the tcpClient and go back to listening
            case READ:
                Serial.print("READ ");
                Serial.println("");
                 // see if we got anything to read
                if((cbRead = tcpClient.available()) > 0){
                    
                    cbRead = cbRead < sizeof(rgbRead) ? cbRead : sizeof(rgbRead);
                    cbRead = tcpClient.readStream(rgbRead, cbRead);
                    Serial.print("Number of bytes read in: ");
                    Serial.print(cbRead,DEC);
                    Serial.println("");
                    
                    lightLED(0,1,0,1);
                    if(char(rgbRead[0]) == '9'){
                        state = CLOSE;
                        for(int i = 0; i < 512; i++){                               //assuming buffer size is 512 - should make a descriptive constant 
                            ReadQueue[i] = 0;
                        }
                    }else if(char(rgbRead[0]) == '1' || char(rgbRead[0]) == '0'){
                        for(int i = 0; i < 512; i++){                              //assuming buffer size is 512 - should make a descriptive constant 
                            ReadQueue[i] = rgbRead[i];
                             Serial.print("rgb Value: ");
                             Serial.println((char)rgbRead[i]);

                        }                 
                        
                        //for(int i =0; i<cbRead;i++){
                        //  Serial.print("ReadQueue Value: ");
                        //  Serial.println((char)ReadQueue[i]);
                        //}
                        //tcpClient.writeStream(ReadQueue, cbRead);  //added this to verify the input from the client
                        //runBUG(ReadQueue);
                        state = WRITE;
                    }
                }else if( (((unsigned) millis()) - tStart) > tWait ){
                    state = READ;
                    Serial.print("timeout ");
                    Serial.println("");
                  
                }
            break;
    
    
            // write back the value of potentiometer
            case WRITE:
                if(tcpClient.isConnected()){
                  Serial.print("Write ");
                  Serial.println("");
                 
                  
                    //read the value of potentiometer
                    steps = analogRead(PM);
                    //convert the value from int to ascii
                    itoa(steps,buffer,10);
                    
                   
                    //put the ascii representation of potentiometer to the buffer
                    for(int i = 0; i < sizeof(rgbWrite); i++){
                        //OUT rgbWrite[i] = byte(buffer[i]);
                        rgbWrite[i] = byte (ReadQueue[i]);
                    }
                    //put a NL - new line to the buffer to know that it is done
                    rgbWrite[sizeof(rgbWrite)-1] = 10; 
                    lightLED(1,1,0,1);
                    //transmit the data back to the control station
                    //tcpClient.writeStream(rgbWrite, sizeof(rgbWrite));
                    tcpClient.writeStream(rgbWrite, sizeof(rgbWrite));
                    state = READ;
                    tStart = (unsigned) millis();
                }else{
                    lightLED(0,0,1,1);
                    state = CLOSE;
                }
            break;
    
            
            // close our tcpClient and go back to listening
            case CLOSE:
                Serial.print("CLOSE ");
                Serial.println("");
                digitalWrite(RELAY, HIGH);
                analogWrite(CLOCK, 0);
                tcpClient.close();
                lightLED(1,0,1,1);     
                state = ISLISTENING;
            break;
    
    
            // something bad happen, just exit out of the program
            case EXIT:
                Serial.print("EXIT ");
                Serial.println("");
                digitalWrite(RELAY, HIGH);
                analogWrite(CLOCK, 0);
                tcpClient.close();
                tcpServer.close();
                lightLED(0,1,1,1);
                state = DONE;
            break;
    
    
            // do nothing in the loop
            case DONE:
            default:
                break;
            }
    
            // every pass through loop(), keep the stack alive
            DNETcK::periodicTasks();
        }
    PT_END(pt);
}
//thread 3 that turns external LED light on and off according to the optical sensor value 
static int protothread3(struct pt *pt, int interval){
    static unsigned long timestamp = 0;
    PT_BEGIN(pt);
    while(1){
        PT_WAIT_UNTIL(pt, millis() - timestamp > interval);
        timestamp = millis();
		OPT_VAL = digitalRead(OPTICAL);
        externalLED(OPT_VAL);
    }
    PT_END(pt);
}
