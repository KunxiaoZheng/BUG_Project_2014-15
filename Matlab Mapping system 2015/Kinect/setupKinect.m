%SETUPKINECT Initialize variables required for the Kinect code to run.
     

%Initializing variables.
averageColorMatrix = 0;
averageDepthMatrix = 0;
numFramesToCapture = 30;

%NUI_IMAGE_STREAM_FLAG_DISTINCT_OVERFLOW_DEPTH_VALUES = 1;

%includes the following functions not included by MATLAB by default, which
%are used by the Kinect code.
utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);

% Create the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1);


depthVid = videoinput('kinect',2);


src = getselectedsource(colorVid);


set(src, 'CameraElevationAngle' , 0);

% Set the triggering mode to 'manual'
triggerconfig([colorVid depthVid],'manual'); 

%start([colorVid depthVid]);

%preview(colorVid);
%preview(depthVid);





