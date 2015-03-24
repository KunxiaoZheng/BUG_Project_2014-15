package GUI;

import java.io.*; 
import java.net.*; 

public class BUGCommunications {

	private String modifiedSentence;
	private String potentiometer;
	private DataOutputStream outToServer;
	private BufferedReader inFromServer;
	private Socket clientSocket; 
	private ControlStationInterface csInterface;
	private int prevJoystickValue;
	
	static private final float leftIncrements = 33.4f;
	static private final float rightIncrements = 25f;
	static private final int centerWheel = 653;
	
	// True = forward, False = reverse
	private boolean directionOfDrive;

	
	public BUGCommunications(ControlStationInterface csInterface){

		directionOfDrive = true;
		this.csInterface = csInterface;
		try {
			clientSocket = new Socket("169.254.1.0", 44400);
			outToServer = new DataOutputStream(clientSocket.getOutputStream());
			inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println("Error creating connection to BUG");
			e.printStackTrace();
		}

		ReadOpticalSensors opticalSensorsComm = new ReadOpticalSensors(this.csInterface);
		opticalSensorsComm.start();
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
		
		//System.out.println("Sending speed of: " + speed);
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
    	//System.out.println("The Control Word is: " + controlWordString);     		
    	this.outToServer.writeBytes( controlWordString );
    	
		modifiedSentence = inFromServer.readLine(); 
		
		potentiometer = modifiedSentence.substring(6,9);
		System.out.println("Potentiometer: " + potentiometer);
		
		
		
		//Grab the First 6 Bytes from the modified Sentence as those are the only bytes being used
		modifiedSentence = modifiedSentence.substring(0,6);
		
		
    	//System.out.print("FROM SERVER: " + modifiedSentence );	
    	//System.out.println("  ( " + modifiedSentence.length() + " Bytes)");
		
    	
    	
		//Check for validity of Server Response
    	if(modifiedSentence.contentEquals(controlWordString)){
    		
    		//System.out.println("Transmition Status: PASS");
    		
    		return true;
    	}else{
    		System.out.println("Modified = "+ modifiedSentence + ", control = "+controlWordString);//"Transmition Status: FAIL");
    		
    		return false;
    	}
    	
    
	}
	
	public void joystickControl() throws IOException{
 		
 		Joystick control = new Joystick();
 		
 		//this value is used to set the factor to which the bugs speed is limited by
 		int speedLimitFactor = 10;
 		
		//speed of bug
		int speed=0;
		String turning = "001";
		
		while(true){
			control.readJoystickValues();
			if(control.update){
			
				if((control.x==0 && control.y==0) || (control.trigger == false)){
					speed = 180;
					this.sendControlWord(turning, speed);
				}
				if(control.y<0 && control.trigger == true ){
					if(directionOfDrive){
						//go forward
						speed = 168+((int)(38*control.y)/speedLimitFactor);
						this.sendControlWord(turning, speed);
					} else {
						//go reverse since the bug is in reverse direction
						speed = 217+(int)(14*control.y);
						this.sendControlWord(turning, speed);
					}
					
				}
				if(control.y>0 && control.trigger == true){
					if(directionOfDrive){
						//go reverse
						speed = 217+(int)(14*control.y);
						this.sendControlWord(turning, speed);
					} else {
						//go forward since the bug is in reverse direction
						speed = 168+((int)(38*control.y)/speedLimitFactor);
						this.sendControlWord(turning, speed);
					}
					
				}
				if(control.x==0){
					turning="000"; // turn right
					this.sendControlWord(turning, speed);
					prevJoystickValue = 0;
				}
				if(control.x>0){ // joystick pressed to right
					
					/* Get the value from joystick and multiply it by 10 and get absolute value and round to an int
					 *  (joystick returns a float from -1.0 (all the way left) to 1.0 (all the way right)
					 *  with 0.1 increments and 0 being the resting state in the center).
					*/ 
					int joystickValue = Math.round(Math.abs(control.x * 10));
					
					// Only move wheel for every second value of the joystick (other wise it its EXTREMELY sensitive to movement)
					if(joystickValue % 2 == 0 && joystickValue != prevJoystickValue){
						prevJoystickValue = joystickValue;
						if(directionOfDrive){
							// In forward operation
							
							// If the wheel angle is less than where it should be, turn wheel more right.
							if((Integer.parseInt(potentiometer)) < 653 + (joystickValue * rightIncrements)){
								while((Integer.parseInt(potentiometer)) < 653 + (joystickValue * rightIncrements)){
									turning="101"; // turn right
									this.sendControlWord(turning, speed);
								}
							}
							
							// If the wheel angle is more than where it should be, turn wheel more left.
							else if((Integer.parseInt(potentiometer)) > 653 + (joystickValue * rightIncrements)){
								while((Integer.parseInt(potentiometer)) > 653 + (joystickValue * rightIncrements)){
									turning="111"; // turn left
									this.sendControlWord(turning, speed);
								}
							}
							
							
						} else {
							// In reverse operation (opposite from above)
							
							// If the wheel angle is less than where it should be, turn wheel more left.
							if((Integer.parseInt(potentiometer)) > 653 - (joystickValue * leftIncrements)){
								while((Integer.parseInt(potentiometer)) > 653 - (joystickValue * leftIncrements)){
									turning="111"; // turn left
									this.sendControlWord(turning, speed);
								}
							}
							
							// If the wheel angle is more than where it should be, turn wheel more left.
							else if((Integer.parseInt(potentiometer)) < 653 - (joystickValue * leftIncrements)){
								while((Integer.parseInt(potentiometer)) < 653 - (joystickValue * leftIncrements)){
									turning="101"; // turn right
									this.sendControlWord(turning, speed);
								}
							}
							
						}
					}
					
					
					
				}
				if(control.x<0){ // joystick pressed to left
					System.out.println(control.x);
					/* Get the value from joystick and multiply it by 10 and get absolute value and round to an int
					 *  (joystick returns a float from -1.0 (all the way left) to 1.0 (all the way right)
					 *  with 0.1 increments and 0 being the resting state in the center).
					*/ 
					int joystickValue = Math.round(Math.abs(control.x * 10));
					
					if(joystickValue % 2 == 0 && joystickValue != prevJoystickValue){
						prevJoystickValue = joystickValue;
						if(directionOfDrive){
							// In forward operation
	
							// If the wheel angle is less than where it should be, turn wheel more left.
							if(Integer.parseInt(potentiometer) > 653 - (joystickValue * leftIncrements)){
								while(Integer.parseInt(potentiometer) > 653 - (joystickValue * leftIncrements)){
									turning="111"; // turn left
									this.sendControlWord(turning, speed);
								}
							}
							
							// If the wheel angle is more than where it should be, turn wheel more right.
							else if(Integer.parseInt(potentiometer) < 653 - (joystickValue * leftIncrements)){
								while(Integer.parseInt(potentiometer) < 653 - (joystickValue * leftIncrements)){
									turning="101"; // turn right
									this.sendControlWord(turning, speed);
								}
							}
								
							
						} else {
							// In reverse operation (opposite from above)
							
							// If the wheel angle is less than where it should be, turn wheel more right.
							if(Integer.parseInt(potentiometer) < 653 + (joystickValue * rightIncrements)){
								while(Integer.parseInt(potentiometer) < 653 + (joystickValue * rightIncrements)){
									turning="101"; // turn right
									this.sendControlWord(turning, speed);
								}
							}
							
							// If the wheel angle is more than where it should be, turn wheel more left.
							else if(Integer.parseInt(potentiometer) > 653 + (joystickValue * rightIncrements)){
								while(Integer.parseInt(potentiometer) > 653 + (joystickValue * rightIncrements)){
									turning="111"; // turn left
									this.sendControlWord(turning, speed);
								}
							}
							
						}
					}
					
				}
				//if(control.z!=0){
					//System.out.println(control.z);
					
				//}
				if(control.button2){
					directionOfDrive = false;
					csInterface.setSecondaryCameraAsMain();
				}
				if(control.button3){
					directionOfDrive = true;
					csInterface.setPrimaryCameraAsMain();
				}/*
				if(control.button4 ){
					if(directionOfDrive){
						//right turn
						turning="111";
						this.sendControlWord(turning, speed);
					} else {
						// turn left since the bug is in reverse direction
						turning="101";
						this.sendControlWord(turning, speed);
					}
					
				}
				if(control.button5 ){
					if(directionOfDrive){
						// turn left
						turning="101";
						this.sendControlWord(turning, speed);
					} else {
						// turn right since the bug is in reverse direction
						turning="111";
						this.sendControlWord(turning, speed);
					}
					
				}*/
				if(!control.button5 && !control.button4){
					turning="001";
					this.sendControlWord(turning, speed);
				}
				
			}	
		
		}	
 	}
	
}
