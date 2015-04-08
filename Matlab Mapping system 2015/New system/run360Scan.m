%Initialize the servo to start from the left most side of the room.
servoPosition = 4200; 

%Initialize the servo moving the Kinect to start from the left most side of the room.
movePololuServo(ser1,'COM6',0,servoPosition);


%Delay added to allow the servo to finish rotating before an image is
%captured.
pause(3);



for i=1:5
    
    %Capture the 1st image of the room and input it into the occupancy grid
    [averageRow, colorFrameData, depthFrameData, averageColorMatrix, averageDepthMatrix ] = averageRowKinectData(colorVid, depthVid, numFramesToCapture );
    [O_Map, E_Map,Loc_points] = MatrixMap(averageRow,K_b_true,xv_true,r_step,grid_x_posn,grid_y_posn,N_cell_x,N_cell_y,E_Map,O_Map,startYaw,Loc_points);
    
    servoPosition = servoPosition + 900;
    
    %Once the image has been captured, rotate the Kinect.
    movePololuServo(ser1,'COM9',0,servoPosition);
    %curr_mpu9150
    pause(3);
    
end
%Set the servo back to centre position
movePololuServo(ser1,'COM9',0,6000);