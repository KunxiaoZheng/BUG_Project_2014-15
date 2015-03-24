package GUI;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;

public class ReadOpticalSensors extends Thread{

	private Socket socket;
	private BufferedReader inFromServer;
	private ControlStationInterface csInterface;
	
	public ReadOpticalSensors(ControlStationInterface csInterface){
		
		this.csInterface = csInterface;
		try {
			this.socket = new Socket("169.254.1.0", 200);
			this.inFromServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	@Override
	   public void run()
	   {
			while(true){
				try {
					System.out.println(inFromServer.read() );
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
			}	 
	   }
}
