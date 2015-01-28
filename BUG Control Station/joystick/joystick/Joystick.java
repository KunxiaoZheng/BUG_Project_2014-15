/******************************************************************
*
*	Copyright (C) Satoshi Konno 1999
*
*	File : Joystick.java
*
******************************************************************/

public class Joystick {

	public static final int BUTTON1 = 0x0001;
	public static final int BUTTON2 = 0x0002;
	public static final int BUTTON3 = 0x0004;
	public static final int BUTTON4 = 0x0008;

	static {
		System.loadLibrary("joystick");
	}		
	
	private int joyID = 0;
	
	public Joystick(int id) {
		joyID = id;
	}

	public native int getNumDevs();
	public native float getXPos(int id);
	public native float getYPos(int id);
	public native float getZPos(int id);
	public native int getButtons(int id);

	public float getXPos() {
		return getXPos(joyID);
	}
	
	public float getYPos() {
		return getYPos(joyID);
	}
	
	public float getZPos() {
		return getZPos(joyID);
	}
	
	public int getButtons() {
		return getButtons(joyID);
	}
	
	public String toString() {
		return "Joystick";
	}
}
