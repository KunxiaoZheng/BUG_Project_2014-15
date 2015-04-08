function [averageRow, colorFrameData, depthFrameData, averageColorMatrix, averageDepthMatrix ] = averageRowKinectData(colorVid, depthVid, numFramesToCapture )
%AVERAGEROWKINECTDATA Captures the data from the Kinect and produces a single row matrix that is to be used by the Occupancy grid.
    %   This function takes runs the other functions below required to generate a single row matrix  ...
    ... to create an occupancy grid. The single row matrix contains the depth distances of any objects/structures in the room.

    %Capture the color and depth frames.
    [colorFrameData,depthFrameData]=kinectGatheringData(colorVid, depthVid, numFramesToCapture);

    %Take the captured frames and find the average.
    [averageColorMatrix, averageDepthMatrix] = averageMultipleFrames(colorFrameData, depthFrameData, numFramesToCapture);

    %Take the averaged color and depth frames, flip them, and find a single row matrix that
    %will be used to create the occupancy grid
    [averageRow,averageColorMatrix, averageDepthMatrix] = manipulatingKinectData(averageColorMatrix, averageDepthMatrix);

end

function [colorFrameData, depthFrameData] = kinectGatheringData(colorVid, depthVid, numFramesToCapture)

    %Set the FramesPerTrigger property of the color and depth objects to capture 'numFramesToCapture' frames per trigger.
    set([colorVid depthVid], 'FramesPerTrigger', numFramesToCapture);

    %Start the color and depth objects. This begins acquisition, but does not start logging of acquired data.
    start([colorVid depthVid]);

    %Trigger the color and depth objects to logging of data.
    trigger([colorVid depthVid]);

    %Retrieve the acquired data and store it in the MATLAB workspace.
    [colorFrameData colorTimeData colorMetaData] = getdata(colorVid);
    [depthFrameData depthTimeData depthMetaData] = getdata(depthVid);
    
    %Stop the color and depth objets from logging data.
    stop([colorVid depthVid]);

end

function [averageColorMatrix, averageDepthMatrix] = averageMultipleFrames(colorFrameData, depthFrameData, numFramesToCapture)

    %Takes the average of the colorFrameData and depthFrameData matrix and takes the average along the 4th ...
    ... dimension. This should return a single frame that is the average of all the frames recorded.
        
    %averageColorFrame = mean(colorFrameData);

    framesCaptured = numFramesToCapture;
    
    %Convert the size of the variables from default 16bits to 64bits. It is done to deal with overflow when ...
    ... adding enough depth distances from multiple frames causes an overflow if variable is only 16bits.
    totalColorMatrix = uint64(colorFrameData(480,640));
    totalDepthMatrix = uint64(depthFrameData(480,640));


        for i=1:numFramesToCapture


            totalColorMatrix = totalColorMatrix + uint64(colorFrameData(:,:,:,i)) ;


            totalDepthMatrix = totalDepthMatrix + uint64(depthFrameData(:,:,:,i)) ;


        end

    averageColorMatrix = round(totalColorMatrix ./ framesCaptured);
    averageDepthMatrix = round(totalDepthMatrix ./ framesCaptured);
    averageColorMatrix = averageColorMatrix ./255; 

    %figure;imagesc(averageColorMatrix);
    %figure;imagesc(averageDepthMatrix);
    
end

function [averageRow,averageColorMatrix, averageDepthMatrix] = manipulatingKinectData(averageColorMatrix, averageDepthMatrix)

    %Flip the image on the vertical axis. Image no longer flipped.

    averageColorMatrix=flipdim(averageColorMatrix, 2);
    averageDepthMatrix=flipdim(averageDepthMatrix, 2);


    %if want to avg multiple images
    %http://www.mathworks.com/matlabcentral/newsreader/view_thread/54395

    %Want to extract individual rows from a matrix. Also can choose individual
    %elements
    %http://stackoverflow.com/questions/7337626/matlab-extracting-rows-of-a-matrix


    %Extracts row 240 from the depthFrameData matrix and stores it in centreRow
    rowData = averageDepthMatrix;
    rowData = averageDepthMatrix([234 236 238 240 242 244 246 ],:);


    %remove zero rows from the matrix
    nonZeroRowData = rowData;
    nonZeroRowData(all(nonZeroRowData==0,2),:)=[];



    %Combine the three rows into one matrix. Allows calculaton of averages
    averageRow=mean(nonZeroRowData(:,1:640));

end

