package test;
import net.java.games.input.*;

import java.io.*; 
import java.net.*; 
/*
Class Description
handles all joystick



*/
public class joystick {

	
	// --------------------VARIABLES----------------------
	
	//analog inputs from the joystick for each of the X,Y,Z axis.
	float x;
	float y;
	float z;
	
	//button inputs from the joystick. These are the buttons on the top of the joystick only
	boolean trigger;
	boolean button2;
	boolean button4;
	boolean button3;
	boolean button5;
	
	//This variable is set to true if any of the inputs from the joystick have changed between the current read and the last read
	boolean update;
	
	static private final int precision = 10;
	
	private Controller joystick;
	
	
	// --------------------Methods----------------------
	
	public joystick (){
		/*Method Description:
		 * This method is the contructor method for the joystick class
		 * Once it is run it will search through all the connected Human Interface Devices for a joystick
		 * If a joystick is found it will:  - connect assign the controller variable joystick to it
		 * 									- gather preliminary data from the buttons to initialize the private variables
		 * 
		 * If a joystick is not found it will output an error message and exit the program
		 */
		
		Controller[] controllers = ControllerEnvironment.getDefaultEnvironment().getControllers();
		this.joystick = null;
		
		//search through all the connected controllers and search for a joystick. Once the joystick is located it
		//assigns it to the joystick variable. If no joystick is found then it outputs an error message and exits
		
		for(int i=0;i<controllers.length && joystick==null;i++) {
           if(controllers[i].getType()==Controller.Type.STICK) {
               // Found a joystick
               this.joystick = controllers[i];
               System.out.println( joystick.getName() +" was Found");
           }
       }
	  
       if(joystick==null) {
    	   //No Joystick was Found output an error message	
    	   System.out.println("No Joystick was Found");
           System.exit(0);
       }
       
       //read in the current values from the joystick
       this.readJoystickValues();
  				
	}
	
	public void readJoystickValues(){
		/*Method Description
		 * This method Reads the joystick values once and assigns the read in values to the classes private variables
		 * This method only reads the joystick ONCE.		 * 
		 * 
		 */
		
		// --------------------VARIABLES----------------------
		
		float readAnalogInput = 0;
		boolean readButtonInput = false;
		boolean change = false;
		
		
		// --------------------CODE----------------------
		//an array of all the components ( ex. Buttons, stick axes) of the joystick
		this.joystick.poll();
		Component[] components = joystick.getComponents();
		
		for(int i=0;i<components.length;i++) {
			
			//reads the values for the component 
			 if(components[i].isAnalog()) {
				 readAnalogInput = components[i].getPollData();
              } else {
                 if(components[i].getPollData()==1.0f) {
                    readButtonInput = true;
                 } else {
                    readButtonInput = false;
                 }
                 
                 //Assigns the class variables the current values of the joystick
              
              }
		
                	 if(i==0){
                		 if((float)(int)(readAnalogInput*precision)/precision!=z){
                			 z = (float)(int)(readAnalogInput*precision)/precision;
                	 		 change=true;
                		                			 
                		 }
					}	
                	
                 
                	 if(i==1){
                		 if((float)(int)(readAnalogInput*precision)/precision!=y){
                			 y = (float)(int)(readAnalogInput*precision)/precision;
                	 		 change=true;
                		                			 
                		 }
					}	
                	
                	 
                	 if(i==2){
                		 if((float)(int)(readAnalogInput*precision)/precision!=x){
                			 x = (float)(int)(readAnalogInput*precision)/precision;
                	 		 change=true;
                		                			 
                		 }
					}	
                	 
                	 if(i==3){
                		 if(readButtonInput!=trigger){
                			 this.trigger = readButtonInput;
                			 change=true;
                		 }
                	 }
				
                	 
                	 if(i==4){
                		 if(readButtonInput!=button2){
                			 this.button2 = readButtonInput;
                			 change=true;
                		 }
                	 }
                	 
                	 if(i==5){
                		 if(readButtonInput!=button3){
                			 this.button3 = readButtonInput;
                			 change=true;
                		 }
                	 }
                	 
                	 if(i==6){
                		 if(readButtonInput!=button4){
                			 this.button4 = readButtonInput;
                			 change=true;
                		 }
                	 }
                	 
                	 if(i==7){
                		 if(readButtonInput!=button5){
                			 this.button5 = readButtonInput;
                			 change=true;
                		 }
                	 }
                	 
                 
              }
			 
			 this.update=change;
		}
	
		
          
	
	public void outputValues(){
		/*Method Description:
		 * Output the private variables for the joystick 
		 */
		
		
		StringBuffer buffer = new StringBuffer();
		
		buffer.append("Z Axis ");
		buffer.append(this.z);
		buffer.append(" Y Axis ");
		buffer.append(this.y);
		buffer.append(" X Axis ");
		buffer.append(this.x);
		buffer.append(" Trigger ");
		buffer.append(this.trigger);
		buffer.append(" Button 2 ");
		buffer.append(this.button2);
		buffer.append(" Button 3 ");
		buffer.append(this.button3);
		buffer.append(" Button 4 ");
		buffer.append(this.button4);
		buffer.append(" Button 5 ");
		buffer.append(this.button5);
		
		System.out.println(buffer.toString());
	}
	public void startJoystickPolling(){
		while(true){
			this.readJoystickValues();
			if(this.update)
				this.outputValues();
				
		}

		
	}
	
	
	public static void main(String[] args) throws IOException {
		joystick control = new joystick();
		//control.startJoystickPolling();
		String sentence;
		String modifiedSentence;
		
		//speed of bug
		int speed=0;
		
		String move = "0000";
		String turn = "00";

		/*while(true){
			control.readJoystickValues();
			if(control.update){
				control.outputValues();
			}
		}*/
				
		
		
		
        BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));
        Socket clientSocket = new Socket("169.254.1.0", 44400);
        DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream());
        BufferedReader inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
	      
	        	//sentence = inFromUser.readLine();
	        	//outToServer.writeBytes(sentence + '\n');
	        	//modifiedSentence = inFromServer.readLine();
	        	//System.out.println("FROM SERVER: " + modifiedSentence);
	        	
	        //clientSocket.close(); 
		
		while(true){
			control.readJoystickValues();
			if(control.update){
				control.outputValues();
				String buffer = new String();
				if(control.x==0 && control.y==0){
					buffer ="000000";
					move="0000";
					System.out.println("outputting: " + buffer);
					outToServer.writeBytes(buffer + '\n');
					modifiedSentence = inFromServer.readLine();
		        	System.out.println("FROM SERVER: " + modifiedSentence);
				}
				if(control.y<0 ){
					speed = 168-(int)(3.8*control.y);
					//buffer =turn+"1180";
					//move="1180";
					buffer ="001150";
					//buffer=buffer.concat(Integer.toString(speed));
					System.out.println("outputting: " + buffer);
					outToServer.writeBytes(buffer + '\n');
					modifiedSentence = inFromServer.readLine();
		        	System.out.println("FROM SERVER: " + modifiedSentence);
				}
				if(control.y==1 ){
					speed = (int)(1.75*control.y)+5;
					//buffer = turn+"1218";
					//move="1218";
					buffer ="001234";
					//buffer=buffer.concat(Integer.toString(speed));
					System.out.println("outputting: " + buffer);
					outToServer.writeBytes(buffer + '\n');
					modifiedSentence = inFromServer.readLine();
		        	System.out.println("FROM SERVER: " + modifiedSentence);
				}
				if(control.x==1 ){
					speed = (int)(1.75*control.y)+5;
					//buffer ="10"+move;
					//turn="10";
					buffer ="100000";
					//buffer=buffer.concat(Integer.toString(speed));
					System.out.println("outputting: " + buffer);
					outToServer.writeBytes(buffer + '\n');
					modifiedSentence = inFromServer.readLine();
		        	System.out.println("FROM SERVER: " + modifiedSentence);
				}
				if(control.x==-1 ){
					speed = (int)(1.75*control.y)+5;
					//buffer ="11"+move;
					//turn="11";
					buffer ="110000";
					//buffer=buffer.concat(Integer.toString(speed));
					System.out.println("outputting: " + buffer);
					outToServer.writeBytes(buffer + '\n');
					modifiedSentence = inFromServer.readLine();
		        	System.out.println("FROM SERVER: " + modifiedSentence);
				}
				
			}	
		
		}		
	
	}

	
}
