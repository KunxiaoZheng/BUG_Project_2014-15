

%The setupSystem script calls the setupKinect, setup9150 and
%setupOccupancyGrid scripts. These functions setup the Kinect, the 9150
%and the Occupancy Grid. After these functions run, the Kinect should be
%ready to capture rgb and depth images, the 9150 should be ready to capture
%the sensor data and the OccupancyGrid should be ready to take the Kinect
%and 9150 data and determine whether a cell in grid is occupied or not.

%setupSystem returns a boolean where if it returns 1 then
%the setup ran successfully, otherwise its 0 and it failed.

%%
%Add folder paths to the project. Allows the folders containing the
%different parts of the project to be accessed.

%addpath(genpath('D:\Google Drive\Fourth Year Project (MIPS)\Occupancy Grid System\Occupancy Grid System code'));
addpath(genpath('C:\Users\jeffchapman-admin\Desktop\Occupancy Grid System\Occupancy Grid System code'));


%%
%DEFINE VARIABLES
global averageRow colorFrameData depthFrameData

%used to set the size of the occupancy grid
occupancyGridSizeX = 400;
occupancyGridSizeY = 400;

%%
 %Pull the orientation of the Kinect from the 9150. Roll, pitch, yaw are
    %saved into orientation as a 1x3 matrix
    orientation = curr_mpu9150;
    
    %Yaw is pulled from orientation variable and saved into yaw variable.
    startYaw = orientation(1,3);

%%
%run individual setup scripts for each part of the system.
%setupKinect
%9150.exe
curr_mpu9150
%setup9150
setupOccupancyGrid
%initializeServo



