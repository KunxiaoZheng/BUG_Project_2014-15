package test;

	
import java.io.*; 
import java.net.*; 
import java.util.Timer;
import java.util.Scanner;
import java.lang.StringBuilder;



class BUGTest{
		
		private String sentence; 
		private String modifiedSentence;
		private DataOutputStream outToServer;
		private BufferedReader inFromServer;
		private Socket clientSocket; 
		
		public BUGTest() throws UnknownHostException, IOException{
			
			clientSocket = new Socket("169.254.1.0", 44400);
			outToServer = new DataOutputStream(clientSocket.getOutputStream());
			inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
		
			
		}
		
		public boolean sendControlWord(String firstThreeBytes, int speed) throws IOException{
			StringBuilder temp = new StringBuilder();
			String controlWordString = "000000";
			
			//check for valid inputs to function
			if(firstThreeBytes.length()>3){
				System.out.println("INVALID INPUT: More then 3 control bytes recieved ( " + firstThreeBytes.length() + " bytes read )" );
				return false;
			}else if (speed >255){
				System.out.println("INVALID INPUT: Speed Too High (Between 0 and 255 accepted)");
				return false;
			}
			
			System.out.println("Sending speed of: " + speed);
        	if(speed<10){
        		
        		temp.append(firstThreeBytes);
        		temp.append("00");
        		temp.append(Integer.toString(speed));
        		
        	}else if(speed<100){
        		
        		temp.append(firstThreeBytes);
        		temp.append("0");
        		temp.append(Integer.toString(speed));
        		
        	}else if(speed>=100){
        		
        		temp.append(firstThreeBytes);
        		temp.append(Integer.toString(speed));        		
        	}
        	
        	//save completed control word to controlWordString Variable
        	controlWordString = temp.toString();
        	
        	//Send the control word to the BUG
        	System.out.println("The Control Word is: " + controlWordString);     		
        	this.outToServer.writeBytes( controlWordString );
    		
    		//read in response from server
        	String tempBitch = "";
        	tempBitch = inFromServer.readLine();
        	/*
        	while(true){
        		
        		if(tempBitch != "")
        		{
        			System.out.println(tempBitch);
        		} else {
        			break;
        		}
        	}
        	*/
    		modifiedSentence = inFromServer.readLine(); 
    		//Grab the First 6 Bytes from the modified Sentence as those are the only bytes being used
    		modifiedSentence = modifiedSentence.substring(0,6);
    		
        	System.out.print("FROM SERVER: " + modifiedSentence );	
        	System.out.println("  ( " + modifiedSentence.length() + " Bytes)");
    		
    		//Check for validity of Server Response
        	if(modifiedSentence.contentEquals(controlWordString)){
        		
        		System.out.println("Transmition Status: PASS");
        		
        		return true;
        	}else{
        		System.out.println("Modified = "+ modifiedSentence + ", control = "+controlWordString);//"Transmition Status: FAIL");
        		
        		return false;
        	}
        	
        
		}
		
		public void cyclePWMInputs(String firstThreeBytes, int start, int stop) throws IOException{
			/** 
			 * Cycles through all the PWM inputs between the ranges of start and stops.
			 * Start and stop values can be between 000 and 999 but only values up to 255 will work.
			 * 
			 * @param start  			a three digit integer that represents the starting PWM value
			 * @param stop   			a three digit integer that represents the PWM value to stop at
			 * @param firstThreeBytes	a string that contains the value of the first three control word bytes to use in the test
			 * @return  	 A boolean indicating whether or not the method was successful
			 * @see BUGTest
			 */
			
			
        	System.out.println("PWM Cycle Test Active: ");
        	System.out.println("Starting PWM = " + start + " Ending PWM = " + stop);
        	System.out.println("Cycling through PWM values...");
			
			
	        for(int x=start;x<=stop;x++){
	        	System.out.println("Desired Speed is" + x);
	        	this.sendControlWord(firstThreeBytes,x);
	        }
	     }
		public boolean manualBugInput(int controlword) throws IOException{
			
			
			//define timer variables
			long endTime;
			long startTime ;
			long lapseTime;
			
						
			//check for valid controlword
			if(Integer.toString(controlword).length() != 6 && controlword!=0){
				System.out.println("invalid control word");
				return false;
			}
				
			
			
			//output the control word to the BUG and gather time stamp of message being sent
			System.out.println("control word is: " + Integer.toString(controlword) ); 
			startTime = System.nanoTime();
    		this.outToServer.writeBytes(Integer.toString(controlword));
    		
    		
    		
    		//read in response from server, and total elapse time for that message
    		modifiedSentence = inFromServer.readLine(); 
    		//Grab the First 6 Bytes from the modified Sentence as those are the only bytes being used
    		modifiedSentence = modifiedSentence.substring(0,6);
    		   		
    		
    		endTime = System.nanoTime();
        	System.out.print("FROM SERVER: " + modifiedSentence );	
        	System.out.println("  ( " + modifiedSentence.length() + " Bytes)");
        	lapseTime = endTime - startTime;
        	System.out.print("Elapse Time: " + lapseTime +" nanoSeconds  ");
        
        	//convert lapse time into more user friendly outputs
        	if(Long.toString(lapseTime).length()<=3){
        		System.out.print("Elapse Time: " + lapseTime +" nanoSeconds  ");	
        	}else if(Long.toString(lapseTime).length()<=6){
				System.out.println("Elapse Time: " + lapseTime/1000 + " microSeconds");
			}else if(Long.toString(lapseTime).length() <=9){
    			System.out.println("Elapse Time: " + lapseTime/1000000 + " milliSeconds");
			}else if(Long.toString(lapseTime).length() >9){	        		
				System.out.println("Elapse Time: " + lapseTime/1000000000 + " Seconds");
        	}
        			
        	
        	
        	//check whether the test worked properly
        	if(modifiedSentence.contentEquals(Integer.toString(controlword))){
        		
        		System.out.println("Test Status: PASS");
        		return true;
        	}else{
        		System.out.println("Test Status: FAIL");
        		return false;
        	}
		}
		public boolean manualBugInput(String controlword) throws IOException{
			//define timer variables
			long endTime;
			long startTime ;
			long lapseTime;
			
			//check for valid controlword
			if(controlword.length() != 6){
				System.out.println("invalid control word");
				return false;
			}
				
			
			
			//output the control word to the BUG and gather time stamp of message being sent
			System.out.println("control word is: " + controlword); 
			startTime = System.nanoTime();
    		this.outToServer.writeBytes(controlword);
    		
    		
    		
    		//read in response from server, and total elapse time for that message
    		modifiedSentence = inFromServer.readLine(); 
    		//Grab the First 6 Bytes from the modified Sentence as those are the only bytes being used
    		modifiedSentence = modifiedSentence.substring(0,6);
    		   		
    		
    		endTime = System.nanoTime();
        	System.out.print("FROM SERVER: " + modifiedSentence );	
        	System.out.println("  ( " + modifiedSentence.length() + " Bytes)");
        	lapseTime = endTime - startTime;
        	System.out.print("Elapse Time: " + lapseTime +" nanoSeconds  ");
        
        	//convert lapse time into more user friendly outputs
        	if(Long.toString(lapseTime).length()<=3){
        		System.out.print("Elapse Time: " + lapseTime +" nanoSeconds  ");	
        	}else if(Long.toString(lapseTime).length()<=6){
				System.out.println("Elapse Time: " + lapseTime/1000 + " microSeconds");
			}else if(Long.toString(lapseTime).length() <=9){
    			System.out.println("Elapse Time: " + lapseTime/1000000 + " milliSeconds");
			}else if(Long.toString(lapseTime).length() >9){	        		
				System.out.println("Elapse Time: " + lapseTime/1000000000 + " Seconds");
        	}
        			
        	
        	
        	//check whether the test worked properly
        	if(modifiedSentence.contentEquals(controlword)){
        		
        		System.out.println("Test Status: PASS");
        		return true;
        	}else{
        		System.out.println("Test Status: FAIL");
        		return false;
        	}
		}
					
	 	public long delayAndAccuracy() throws IOException{
	 		/**
	 		 * Checks for the accuracy and latency of the network connection to the BUG.
	 		 * It does this by cycling through all the possible inputs for the BUG's control word. 
	 		 * As it does this it records statistics on the latency of every message sent as well as whether or not the message was
	 		 * sent and recieved correctly. Once the test is completed it prints out a number of useful statistics
	 		 * 
	 		 * ***get this to write to a file***
			 * 
			 * @param NULL
			 * @return  void
			 * @see BUGTest
			 */
	 		
	 		//test variables
	 		String firstThreeBytes;
	 		StringBuilder temp = new StringBuilder();
	 		int itteration = 1;
	 		boolean[] result = new boolean[2040];
	 		long averageLatency =0;
	 		int numSuccess = 0;
	 		int numFail = 0;
	 		
			//define timer variables
			long endTime;
			long startTime ;
			long lapseTime;
			long maxLatency = 0;
			long minLatency = 0;
	 		long[] latencies = new long[2040];
	 		
	 		
	 		for(int x = 0; x<8;x++){
	 			
	 			if(x==0){
	 				temp.append("000");
	 			}else if (x==1){
	 				temp.append("001");
	 			}else if (x==2){
	 				temp.append("011");
	 			}else if (x==3){
	 				temp.append("010");
	 			}else if (x==4){
	 				temp.append("100");
	 			}else if (x==5){
	 				temp.append("101");
	 			}else if (x==6){
	 				temp.append("111");
	 			}else if (x==7){
	 				temp.append("110");
	 			}
	 			firstThreeBytes = temp.toString();
	 			for(int y = 0; y<255; y++){
	 				
	 				System.out.println("");
		 			System.out.println("Itteration: "+ itteration);
	 				
	 				//send message and gather latency
	 				
	 				startTime = System.nanoTime();
	 				result[itteration-1] = this.sendControlWord(firstThreeBytes, y);
	 				endTime = System.nanoTime();
	 				
	 				lapseTime = endTime - startTime;
	 				latencies[itteration-1] = lapseTime;
	 				
	 				//calculate average latency
	 				averageLatency = 0;
	 				for(int z=0;z<itteration;z++){
	 					averageLatency = averageLatency + latencies[z];
	 				}
	 				
	 				//Latency Portion of Test
	 				averageLatency = averageLatency/itteration;
	 				if(itteration == 1)
	 					minLatency = averageLatency;
	 				if(averageLatency>maxLatency)
	 					maxLatency = averageLatency;
	 				if(averageLatency<minLatency)
	 					minLatency = averageLatency;
	 				
	 				System.out.print("Message Latency: " + latencies[itteration-1] +" nanoSeconds  ");
	 				System.out.println("Average Latency: " + averageLatency + " nanoseconds");
	 				
	 				itteration++;
	 			}
	 			temp.delete(0,temp.length());
	 			
	 		}
	 		
	 		//Check for successful tests
	 			for(int x =0; x<itteration-1; x++){
	 				if( result[x] == true){
	 					numSuccess++;
	 				}else {
	 					numFail++;
	 				}
 				}
	 			
	 		//Print OUt Results
	 			System.out.println("                       RESULTS");
	 			System.out.println("Number of Messages Sent:       " + (itteration-1));
	 			System.out.println("Number of Successful messages: " + numSuccess);
	 			System.out.println("Number of failed messages:     " + numFail);
	 			System.out.println("");
	 			System.out.println("Maximum Latency: 				 " + maxLatency);
	 			System.out.println("Minimum Latency: 				 " + minLatency);
	 			System.out.println("Average Latency: 				 " + averageLatency);
	 			
	 		return 0;
	 	}

	 	public void joystickControl() throws IOException{
	 		
	 		joystick control = new joystick();
	 		
	 		//this value is used to set the factor to which the bugs speed is limited by
	 		int speedLimitFactor = 10;
	 		
			//speed of bug
			int speed=0;
			String turning = "001";
			
			while(true){
				control.readJoystickValues();
				if(control.update){
					control.outputValues();
				
					if((control.x==0 && control.y==0) || (control.trigger == false)){
						speed = 180;
						this.sendControlWord(turning, speed);
					}
					if(control.y<0 && control.trigger == true ){
						//Forward
						speed = 168+((int)(38*control.y)/speedLimitFactor);
						this.sendControlWord(turning, speed);
						
					}
					if(control.y>0 && control.trigger == true){
						//reverse
						speed = 217+(int)(14*control.y);
						this.sendControlWord(turning, speed);
					}
					if(control.button4 ){
						//right turn
						turning="111";
						this.sendControlWord(turning, speed);
					}
					if(control.button5 ){
						//left turn
						turning="101";
						this.sendControlWord(turning, speed);
						
					}
					if(!control.button5 && !control.button4){
						turning="001";
						this.sendControlWord(turning, speed);
					}
					
				}	
			
			}	
	 	}
	 	
	    public static void main(String argv[]) throws Exception { 
	      	//VARIABLES
	    	BUGTest test1 	   = new BUGTest();
	      	int test 		   = 1;					//used to determine current test
	      	int numTestCases   = 4;
	      	boolean testStatus = true;  
	      	boolean end = false;
	      	
	      	Scanner in = new Scanner(System.in);
	      	String userInput;
	      	
	      	//test case 1 variables
	      	String manualControlWord;
	      	
	      	//test case 2 variables
	      	int start = 0;
	      	int stop  = 0;
	      	
	      	while(!end){
	      	
	      		System.out.println("");
		      	System.out.println("             BUG Testing Application");
		      	System.out.println("");
		      	System.out.println("Choose which of the following test cases to run");
		      	System.out.println("TESTS:");
		      	System.out.println("1    Manual Test");
		      	System.out.println("2    cycle PWM values from a start value to and end value");
		      	System.out.println("3    Check Channel Latency and Accuracy");
		      	System.out.println("4    Joystick Control");
		      	System.out.println("0    EXIT ");
		      	System.out.println("");
		      	System.out.println("Pick Test to Run");
		      	test = in.nextInt();
		      		if(test>numTestCases){
		      			System.out.println("INVALID INPUT");
			      	}else{
			      	
				      	switch (test){
				      	
				      	case 1:
				      	
				      	System.out.println("TEST 1:            				 Manual Test");
				      	System.out.println("		Control word Format: 'xxxxxx' where each x is a byte");
				      	System.out.println("		first two bits are motor direction and the last 4 are for motor speed");
				      	System.out.println("		Enter A Control Word for the BUG...");
				      	manualControlWord = in.next();
				      	testStatus = test1.manualBugInput(manualControlWord);
				        
				      	break;
				      	
				      	case 2:
				      		
				      	System.out.println("TEST 2:             				Cycle PWM values ");
				      	System.out.println("		cycles through all the PWM values within a set range");
				      	System.out.println("");
				      	System.out.println("Enter the starting PWM Value");
				      	start = in.nextInt();
				      	System.out.println("Enter the Final PWM Value");
				      	stop = in.nextInt();
				      			      	
				       	test1.cyclePWMInputs("001",start,stop);
				       	
				       	break;
				       	
				      	case 3:
				      		System.out.println("TEST 3:             			Check Socket Delay and accuracy ");
					      	System.out.println("		Sends all the possible permutations of the control word to verify they all work");
					      	System.out.println("		As it is doing that it takes latency measurements to calculate the average latency time");
					      	System.out.println("");
					      	
					      	test1.delayAndAccuracy();
				       	
					    break;
					    

				      	case 4:
				      		System.out.println("TEST 4:             			JOYSTICK CONTROL. ");
					      	System.out.println("		Control The BUG's drive and turning motors using the joystick");
					      	System.out.println("");
					      	
					      	test1.joystickControl();
					      	
				       	default :
				       	
				       	System.out.println("Closing Test Application");
				       	//telling server that the socket is closing
				       	test1.outToServer.writeBytes("9\n");
				        test1.clientSocket.close(); 
				        end = true;
				        
				        break;
				        
				      }
			      }
		     }
	    } 
	}


