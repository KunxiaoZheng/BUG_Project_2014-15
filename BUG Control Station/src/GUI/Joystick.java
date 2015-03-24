package GUI;

import net.java.games.input.*;

import java.io.*;
import java.net.*;

/*
 Class Description
 handles all joystick



 */
public class Joystick {

	// --------------------VARIABLES----------------------

	// analog inputs from the joystick for each of the X,Y,Z axis.
	float x;
	float y;
	float z;

	// button inputs from the joystick. These are the buttons on the top of the
	// joystick only
	boolean trigger;
	boolean button2;
	boolean button4;
	boolean button3;
	boolean button5;

	// This variable is set to true if any of the inputs from the joystick have
	// changed between the current read and the last read
	boolean update;

	static private final int precision = 10;

	private Controller joystick;

	// --------------------Methods----------------------

	public Joystick() {
		/*
		 * Method Description: This method is the contructor method for the
		 * joystick class Once it is run it will search through all the
		 * connected Human Interface Devices for a joystick If a joystick is
		 * found it will: - connect assign the controller variable joystick to
		 * it - gather preliminary data from the buttons to initialize the
		 * private variables
		 * 
		 * If a joystick is not found it will output an error message and exit
		 * the program
		 */

		Controller[] controllers = ControllerEnvironment
				.getDefaultEnvironment().getControllers();
		this.joystick = null;

		// search through all the connected controllers and search for a
		// joystick. Once the joystick is located it
		// assigns it to the joystick variable. If no joystick is found then it
		// outputs an error message and exits

		for (int i = 0; i < controllers.length && joystick == null; i++) {
			if (controllers[i].getType() == Controller.Type.STICK) {
				// Found a joystick
				this.joystick = controllers[i];
				System.out.println(joystick.getName() + " was Found");
			}
		}

		if (joystick == null) {
			// No Joystick was Found output an error message
			System.out.println("No Joystick was Found");
			System.exit(0);
		}

		// read in the current values from the joystick
		this.readJoystickValues();

	}

	public void readJoystickValues() {
		/*
		 * Method Description This method Reads the joystick values once and
		 * assigns the read in values to the classes private variables This
		 * method only reads the joystick ONCE. *
		 */

		// --------------------VARIABLES----------------------

		float readAnalogInput = 0;
		boolean readButtonInput = false;
		boolean change = false;

		// --------------------CODE----------------------
		// an array of all the components ( ex. Buttons, stick axes) of the
		// joystick
		this.joystick.poll();
		Component[] components = joystick.getComponents();

		for (int i = 0; i < components.length; i++) {

			// reads the values for the component
			if (components[i].isAnalog()) {
				readAnalogInput = components[i].getPollData();
			} else {
				if (components[i].getPollData() == 1.0f) {
					readButtonInput = true;
				} else {
					readButtonInput = false;
				}

				// Assigns the class variables the current values of the
				// joystick

			}

			if (i == 0) {
				if ((float) (int) (readAnalogInput * precision) / precision != z) {
					z = (float) (int) (readAnalogInput * precision) / precision;
					change = true;

				}
			}

			if (i == 1) {
				if ((float) (int) (readAnalogInput * precision) / precision != y) {
					y = (float) (int) (readAnalogInput * precision) / precision;
					change = true;

				}
			}

			if (i == 2) {
				if ((float) (int) (readAnalogInput * precision) / precision != x) {
					x = (float) (int) (readAnalogInput * precision) / precision;
					change = true;

				}
			}

			if (i == 3) {
				if (readButtonInput != trigger) {
					this.trigger = readButtonInput;
					change = true;
				}
			}

			if (i == 4) {
				if (readButtonInput != button2) {
					this.button2 = readButtonInput;
					change = true;
				}
			}

			if (i == 5) {
				if (readButtonInput != button3) {
					this.button3 = readButtonInput;
					change = true;
				}
			}

			if (i == 6) {
				if (readButtonInput != button4) {
					this.button4 = readButtonInput;
					change = true;
				}
			}

			if (i == 7) {
				if (readButtonInput != button5) {
					this.button5 = readButtonInput;
					change = true;
				}
			}

		}

		this.update = change;
	}

}
