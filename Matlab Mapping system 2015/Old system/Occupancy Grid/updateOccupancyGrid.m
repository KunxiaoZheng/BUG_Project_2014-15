%
%This script runs the methods found within the occupancyGrid class on the
%three occupancy grid objects. A complete update Occupancy Grid cycle is
%performed in the following steps
%
%step 1: grab the single Frame Data from the Kinect Camera
%
%step 2: Construct an occupancyGrid representation for that single depth image 
%        and store it in the singleFrameOG object
%
%step 3: Rotate the singleFrameOG by the yaw value collected from the 9150
%
%step 4: update the master occupancy grid based off of the
%        singleFrameRotatedOG we just created
%    

%%
%GATHER KINECT DATA
 
    %Grab The Single Frame Data From The Kinect Camera
    [averageRow, colorFrameData, depthFrameData, averageColorMatrix, averageDepthMatrix] = averageRowKinectData(colorVid, depthVid, numFramesToCapture);

    %Construct the single image occupancy Grid from the average row data
    singleFrameOG.buildGridFromDepthImage(averageRow)

%%
%GATHER 9150 DATA
    
    %Pull the orientation of the Kinect from the 9150. Roll, pitch, yaw are
    %saved into orientation as a 1x3 matrix
    orientation = curr_mpu9150;
    
    %Yaw is pulled from orientation variable and saved into yaw variable.
    yaw = orientation(1,3);

%%
%COMBINE DATA AND CONSTRUCT OCCUPANCY GRID

    %Rotate the single Image by the value passed in( rorateSingleFrame(value) )
    singleFrameRotatedOG.grid = singleFrameOG.rotateSingleFrameOG(yaw);


    %Combine the data from the singleFrame RotatedOG into the Master Occupancy
    %Grid
    masterGrid.updateMasterOG(singleFrameRotatedOG);
    figure,imagesc(masterGrid.grid);
    
    %Reset Single frame and rotated occupancy Grid
    singleFrameOG.resetGrid();
    singleFrameRotatedOG.resetGrid();
