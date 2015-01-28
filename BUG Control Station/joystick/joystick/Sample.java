/******************************************************************
*
*	Copyright (C) Satoshi Konno 1999
*
*	File : Sample.java
*
******************************************************************/

public class Sample {

	public static void main(String args[]) {
		Joystick joy = new Joystick(0);
		while (true) {
			System.out.println("(x,y) = " + joy.getXPos() + ", " + joy.getYPos() + "," + Integer.toHexString(joy.getButtons()));
		}
	}
}
