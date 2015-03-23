package GUI;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

import javax.swing.*;

import com.sun.jna.Native;
import com.sun.jna.NativeLibrary;

import uk.co.caprica.vlcj.binding.LibVlc;
import uk.co.caprica.vlcj.player.MediaPlayerFactory;
import uk.co.caprica.vlcj.player.embedded.EmbeddedMediaPlayer;
import uk.co.caprica.vlcj.player.embedded.videosurface.CanvasVideoSurface;
import uk.co.caprica.vlcj.runtime.RuntimeUtil;


public class ControlStationInterface extends JPanel {
    /**
	 * 
	 */
	public static ControlStationInterface csInterface;
	
	private static final long serialVersionUID = 1L;
	private static EmbeddedMediaPlayer primaryMediaPlayer;
	private static EmbeddedMediaPlayer secondaryMediaPlayer;
	private static MediaPlayerFactory primaryMediaPlayerFactory;
	private static MediaPlayerFactory secondaryMediaPlayerFactory;
	private static CanvasVideoSurface primaryVideoSurface;
	private static CanvasVideoSurface secondaryVideoSurface;
	private static JFrame frame;
	private JPanel primaryPanel;
	private JPanel secondaryPanel;
	private JPanel infoPanel;
	private JPanel buttonPanel;
	private JPanel contentPanel;
	
	
			
	public ControlStationInterface(String mainCamera) {
		
		/*
		 * Info contents
		 */
        infoPanel = new JPanel();
        infoPanel.setBackground(Color.BLUE);
        infoPanel.setPreferredSize(new Dimension(300, 150));
        
        JLabel systemLabel = new JLabel("<html><div style=\"text-align: center;\">System Info <br>(battery, orientation, etc)</html>");
        systemLabel.setForeground(Color.WHITE);
        infoPanel.add(systemLabel);

        /*
         * Secondary view contents
         */
        secondaryPanel = new JPanel();
        secondaryPanel.setLayout(new BorderLayout());
        
        // Set size of window depending on which camera is the main
        if(mainCamera.equals("secondary")){
        	secondaryPanel.setPreferredSize(new Dimension(900, 500));
        } else if(mainCamera.equals("primary")){
        	secondaryPanel.setPreferredSize(new Dimension(300, 150));
        } else {
        	System.out.println("ERROR: invalid main camera entered.");
        }
        
        // An EmbeddedMediaPlayer cannot be added directly to a JPanel so it is added to a canvas instead
        Canvas secondaryCanvas = new Canvas();
        secondaryPanel.add(secondaryCanvas, BorderLayout.CENTER);
        secondaryCanvas.setVisible(true);

        secondaryMediaPlayerFactory = new MediaPlayerFactory();
        secondaryVideoSurface = secondaryMediaPlayerFactory.newVideoSurface(secondaryCanvas);
        secondaryMediaPlayer = secondaryMediaPlayerFactory.newEmbeddedMediaPlayer();
        secondaryMediaPlayer.setVideoSurface(secondaryVideoSurface);
        

        /*
         * Button contents
         */
        buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
        buttonPanel.setBackground(Color.WHITE);
        buttonPanel.setPreferredSize(new Dimension(300, 150));
        
        JButton captureButton = new JButton("Capture Room");
        captureButton.setPreferredSize(new Dimension(300, 75));
        captureButton.addActionListener(new ActionListener() {
    		@Override
    		public void actionPerformed(ActionEvent e) {
    			setPrimaryCameraAsMain();
    			
    			//JFrame viewRoomFrame = new JFrame("Current Room View");
    			//viewRoomFrame.setVisible(true);
    			//viewRoomFrame.setLocationRelativeTo(null);
    		}
        });
        buttonPanel.add(captureButton);
        
        JButton viewButton = new JButton("View Room");
        viewButton.setPreferredSize(new Dimension(300, 75));
        viewButton.addActionListener(new ActionListener() {
    		@Override
    		public void actionPerformed(ActionEvent e) {
    			setSecondaryCameraAsMain();
    			JFrame viewRoomFrame = new JFrame("Current Room View");
    			viewRoomFrame.setVisible(true);
    			viewRoomFrame.setLocationRelativeTo(null);
    			
    			ImageIcon image = new ImageIcon("images/mini.jpg");
    			JLabel label = new JLabel("", image, JLabel.CENTER);
    			JPanel panel = new JPanel(new BorderLayout());
    			panel.add( label, BorderLayout.CENTER );
    			viewRoomFrame.setContentPane(panel);
    			viewRoomFrame.pack();
    		}
        });
        buttonPanel.add(viewButton);
        
        
        /*
         * Primary view contents
         */
        primaryPanel = new JPanel();
        primaryPanel.setLayout(new BorderLayout());
        
        // Set size of window depending on which camera is the main
        if(mainCamera.equals("primary")){
        	primaryPanel.setPreferredSize(new Dimension(900, 500));
        } else if(mainCamera.equals("secondary")){
        	primaryPanel.setPreferredSize(new Dimension(300, 150));
        } else {
        	System.out.println("ERROR: invalid main camera entered.");
        }
        
        // An EmbeddedMediaPlayer cannot be added directly to a JPanel so it is added to a canvas instead
        Canvas primaryCanvas = new Canvas();
        primaryPanel.add(primaryCanvas, BorderLayout.CENTER);
        primaryCanvas.setVisible(true);
        
        primaryMediaPlayerFactory = new MediaPlayerFactory();
        primaryMediaPlayer = primaryMediaPlayerFactory.newEmbeddedMediaPlayer();
        primaryVideoSurface = primaryMediaPlayerFactory.newVideoSurface(primaryCanvas);
        primaryMediaPlayer.setVideoSurface(primaryVideoSurface);

        /*
         * Add all panels to the contentPanel to be added to the frame.
         */
        if(mainCamera.equals("primary")){
        	contentPanel = new JPanel();
            contentPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
            contentPanel.setPreferredSize(new Dimension(900, 650));
            contentPanel.add(infoPanel);
            contentPanel.add(secondaryPanel);
            contentPanel.add(buttonPanel);
            contentPanel.add(primaryPanel);
            
            add(contentPanel, BorderLayout.CENTER);
        	
        } else if(mainCamera.equals("secondary")){
        	contentPanel = new JPanel();
            contentPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
            contentPanel.setPreferredSize(new Dimension(900, 650));
            contentPanel.add(infoPanel);
            contentPanel.add(primaryPanel);
            contentPanel.add(buttonPanel);
            contentPanel.add(secondaryPanel);
            
            add(contentPanel, BorderLayout.CENTER);
        	
        } else {
        	System.out.println("ERROR: invalid main camera entered.");
        }
        
    }
	
	public void setPrimaryCameraAsMain(){
		secondaryMediaPlayer.stop();
        primaryMediaPlayer.stop();
		frame.remove(contentPanel);
		csInterface = new ControlStationInterface("primary");
		frame.setContentPane(csInterface);
		frame.pack();
		frame.invalidate();
        frame.validate();
        
        secondaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\RoadBikeParty.mp4");
        primaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\BikeParkour.mp4");
	
	}
	
	public void setSecondaryCameraAsMain(){
		secondaryMediaPlayer.stop();
        primaryMediaPlayer.stop();
		frame.remove(contentPanel);
		csInterface = new ControlStationInterface("secondary");
		frame.setContentPane(csInterface);
		frame.pack();
		frame.invalidate();
        frame.validate();
        
        secondaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\RoadBikeParty.mp4");
        primaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\BikeParkour.mp4");
		
	}
	
	public void setPotentiometer(String value){
		
		System.out.println("Potentiometer = " + value);
		
	}


	public static void main(String s[]) {
    	
    	//used to import the library needed to use vlcj
        NativeLibrary.addSearchPath(
        RuntimeUtil.getLibVlcLibraryName(), "./vlc-2.1.1");
        Native.loadLibrary(RuntimeUtil.getLibVlcLibraryName(), LibVlc.class);
        
        // Create the JFrame
    	frame = new JFrame("BUG Control Station");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setContentPane(csInterface = new ControlStationInterface("primary"));
        frame.setResizable(false);
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        
        // Start the EmbeddedMediaPlayers 
        secondaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\RoadBikeParty.mp4");
        primaryMediaPlayer.playMedia("C:\\Users\\Andrew\\Downloads\\BikeParkour.mp4");
        //secondaryMediaPlayer.playMedia("http://192.168.1.110:8080/?action=stream");
        //primaryMediaPlayer.playMedia("http://192.168.1.110:8081/?action=stream");
        
        //MatlabCommunications matComm = new MatlabCommunications();
        //matComm.start();
        
        // Start communication with the BUG
 		BUGCommunications bugComm = new BUGCommunications(csInterface);
 		
 		// Start the joystick functionality
 		
 		try {
 			bugComm.joystickControl();
 		} catch (IOException e) {
 			// TODO Auto-generated catch block
 			System.out.println("Error starting the joystick.");
 			e.printStackTrace();
 		}
    }
}



