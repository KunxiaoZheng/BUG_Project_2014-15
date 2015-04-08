%RUNAVERAGEROWKINECTDATA Runs the averageRowKinectData() function with required inputs
    %   This MATLAB scripts takes the averageRowKinectData() function and
    %   inputs the required parameters to run the function. 

[averageRow, colorFrameData, depthFrameData, averageColorMatrix, averageDepthMatrix ] = averageRowKinectData(colorVid, depthVid, numFramesToCapture );
%figure;imagesc(averageColorMatrix);
%figure;imagesc(averageDepthMatrix);