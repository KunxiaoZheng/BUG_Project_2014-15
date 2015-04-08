%Creating the grid that displays the probability of whether an object
%exists or not on the map. Each 1x1cm cell in the occupancy grid represents
%a 1x1 cell in the real world captured by the Kinect. At initialization,
%z is 0.5 for every coordinate. meaning that there is an equal chance of
%the cell being occupied and being empty.
%(50% chance occupied, 50% chance empty)

%Create an array for x and y starting from a value of -400 up to 400. This
%will be used to generate the 400x400cm grid
yArray = [-400:1:400];
xArray = [-400:1:400];

%Creates a meshgrid which is a 400x400cm grid.
[x,y] = meshgrid(xArray,yArray);

%%
%Defining system occupancy grids used to build the map

%Creates the master occupancyGrid which is where the final occupancy grid
%will be stored
masterGrid = occupancyGrid;
%This is the occupancyGrid that stores the temporary occupancygrid for each
%depth frame before they are maniluplated and combined to the master grid
singleFrameOG = occupancyGrid;
%This is the Occupancy Grid for the rotated single frame. It is rotated
%with respect to the yaw value read in from the 9150 sensor package 
singleFrameRotatedOG = occupancyGrid;
%holding the value of the full grid
%FullGrid = occupancyGrid;
%setGridSize(4000, 4000, FullGrid); %enlarge the FullGrid so it can hold a full room %assuming 4000x4000 is big enough. test later
