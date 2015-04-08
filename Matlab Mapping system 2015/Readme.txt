To run this Matlab code. First add this folder to the path. To do this, navigate to the folder in
MAtlab, right click on it, under "add to path" click folders and subfolders.

This will ensure that Matlab knows where to find all of the files required.

Now, run the 9150 code (located in the 9150 folder, see readme in that folder for how to run it)

Once the 9150 code is running, make sure everything is plugged in, and the drivers have finished installing.

If running this system on a new computer, check the files to install folder in the main directory.

Once drivers have been installed, check the com port of the pololu servo controller. 
The port you want for this is the command port.
Change the port number in "initializeServo.m" (under the pololu servo microcontroller folder) to match.

The system should be ready to run.


Run the system by doing the following MAtlab calls

-initialize_hardware
-SetupSystem


if running map tests, use
-[averageRow, colorFrameData, depthFrameData, averageColorMatrix, averageDepthMatrix ] = averageRowKinectData(colorVid, depthVid, numFramesToCapture );
-[O_Map, E_Map,Loc_points] = MatrixMap(averageRow,K_b_true,xv_true,r_step,grid_x_posn,grid_y_posn,N_cell_x,N_cell_y,E_Map,O_Map,startYaw,Loc_points);

This will receive one Kinect depth image, then create a map, and display a log of the empty space.


if running the fully system, use
-run360Scan

This will turn the servo to 5 positions, take the 9150 data, and add each Kinect depth value based on
the correct yaw information. 
If the 9150 is not connected, then the map will place all 5 of the Kinect depth value sets based on
an old yaw value from the 9150.


IF you want to move the BUG (position of the Kinect around the map), use
-[xv_true,Loc_points, roundingError, P_Map] = move_BUG(pot_val, left_vel, right_vel, t, xv_true,Loc_points, start_yaw, roundingError, P_Map);

replace "pot_val", "left_vel", "right_vel", and "t" with corresponding test values, or comment out the call to
"howMuch" and uncomment "position = [5 0];"
replacing 5 and 0 with the test [x y] displacement. 


