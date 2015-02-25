package GUI;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

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
	private static final long serialVersionUID = 1L;
	private static EmbeddedMediaPlayer primaryMediaPlayer;
	private static EmbeddedMediaPlayer secondaryMediaPlayer;
	private static MediaPlayerFactory primaryMediaPlayerFactory;
	private static MediaPlayerFactory secondaryMediaPlayerFactory;
	private static CanvasVideoSurface primaryVideoSurface;
	private static CanvasVideoSurface secondaryVideoSurface;
			
	public ControlStationInterface() {
		
		/*
		 * Info contents
		 */
        JPanel infoPanel = new JPanel();
        infoPanel.setBackground(Color.BLUE);
        infoPanel.setPreferredSize(new Dimension(300, 150));
        
        JLabel systemLabel = new JLabel("<html><div style=\"text-align: center;\">System Info <br>(battery, orientation, etc)</html>");
        systemLabel.setForeground(Color.WHITE);
        infoPanel.add(systemLabel);

        /*
         * Secondary view contents
         */
        JPanel secondaryPanel = new JPanel();
        secondaryPanel.setLayout(new BorderLayout());
        secondaryPanel.setPreferredSize(new Dimension(300, 150));
        
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
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
        buttonPanel.setBackground(Color.WHITE);
        buttonPanel.setPreferredSize(new Dimension(300, 150));
        
        JButton captureButton = new JButton("Capture Room");
        captureButton.setPreferredSize(new Dimension(300, 75));
        buttonPanel.add(captureButton);
        
        JButton viewButton = new JButton("View Room");
        viewButton.setPreferredSize(new Dimension(300, 75));
        viewButton.addActionListener(new ActionListener() {
    		@Override
    		public void actionPerformed(ActionEvent e) {
    			
    			JFrame viewRoomFrame = new JFrame("Current Room View");
    			viewRoomFrame.setVisible(true);
    			viewRoomFrame.setLocationRelativeTo(null);
    		}
        });
        buttonPanel.add(viewButton);
        
        
        /*
         * Primary view contents
         */
        JPanel primaryPanel = new JPanel();
        primaryPanel.setLayout(new BorderLayout());
        primaryPanel.setPreferredSize(new Dimension(900, 500));
        
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
        JPanel contentPanel = new JPanel();
        contentPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
        contentPanel.setPreferredSize(new Dimension(900, 650));
        contentPanel.add(infoPanel);
        contentPanel.add(secondaryPanel);
        contentPanel.add(buttonPanel);
        contentPanel.add(primaryPanel);
        
        add(contentPanel, BorderLayout.CENTER);
    }
	
	
	
    public static void main(String s[]) {
    	
    	//used to import the library needed to use vlcj
        NativeLibrary.addSearchPath(
        RuntimeUtil.getLibVlcLibraryName(), "./vlc-2.1.1");
        Native.loadLibrary(RuntimeUtil.getLibVlcLibraryName(), LibVlc.class);
    	
    	System.setProperty("jna.library.path", "C:\\Users\\Andrew\\Documents\\workspace\\BUG Control Station\\java build paths");
        
    	JFrame frame = new JFrame("BUG Control Station");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setContentPane(new ControlStationInterface());
        //frame.setResizable(false);
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        
        secondaryMediaPlayer.playMedia("http://192.168.1.110:8080/?action=stream");
        //secondaryMediaPlayer.playMedia("C:\\Users\\Public\\Videos\\Sample Videos\\Wildlife.wmv");
        primaryMediaPlayer.playMedia("http://192.168.1.110:8081/?action=stream");
    }
}



