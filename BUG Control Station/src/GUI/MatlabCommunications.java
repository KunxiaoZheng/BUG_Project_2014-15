package GUI;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;

import javax.imageio.ImageIO;

public class MatlabCommunications extends Thread{

	/*
	private DataOutputStream outToServer;
	private BufferedReader inFromServer;
	private Socket clientSocket; 
	private InputStream inputStream;
	*/
	private Socket socket;
	private Socket socketOut;
	private BufferedReader in;
	private DataOutputStream outToServer;
	
	
	public MatlabCommunications(){
		
		try {
			socket = new Socket("192.168.1.102", 8090);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            outToServer = new DataOutputStream(socket.getOutputStream());
            /*
            socketOut = new Socket("192.168.1.102", 8091);
            outToServer = new DataOutputStream(socketOut.getOutputStream());
            /*
			clientSocket = new Socket("192.168.1.102", 8090);
			outToServer = new DataOutputStream(clientSocket.getOutputStream());
			inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
			inputStream = clientSocket.getInputStream();*/
			System.out.println("Connected to MatLab");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println("Error creating connection to BUG");
			e.printStackTrace();
		}
	}
	
	@Override
	   public void run()
	   {

		System.out.println("Starting");
			while(true){
				String serverResponse = null;

					try {
						while ((serverResponse = in.readLine()) != null){
							if(serverResponse.equals("test")){
								System.out.println(serverResponse);
								System.out.println("Test Received");
								outToServer.writeBytes("echo");
								
							}
							
							serverResponse = null;
						}
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				/*try {

					String modifiedSentence = inFromServer.readLine(); 
					System.out.println(modifiedSentence);
					BufferedImage img=ImageIO.read(ImageIO.createImageInputStream(clientSocket.getInputStream()));
					System.out.println("Images received");
					File outputfile = new File("//images//test.png");
				    ImageIO.write(img, "png", outputfile);
				    
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}*/

			}
			
			 
	   }
}
