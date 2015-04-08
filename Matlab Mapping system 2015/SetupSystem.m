%--------------------------------------------------------------   
%                       Initial Setup of system
%--------------------------------------------------------------
%add everything to the path
%addpath(genpath('C:\Users\jeffchapman-admin\Desktop\Occupancy Grid System\Occupancy Grid System code'));
%addpath(genpath('C:\Users\jeffchapman-admin\Desktop\Mapping System\Occupancy Grid System code'));

% setup occupancy grid & variables
    %DEFINE VARIABLES
    global averageRow colorFrameData depthFrameData

    %used to set the size of the occupancy grid
    map_size_x = 50;   %Horizontal map size in metres
    map_size_y = 50;   %Vertical map size in metres
    grid_space_x = 0.25; %0.25; %0.5; %1.0; %0.1; %Horizontal grid spacing in m
    grid_space_y = 0.25; %0.25; %0.5; %1.0;  %0.1; %Vertical grid spacing in m
    %100m x 100m grid size
    
    grid_start_x = 0; %Horizontal position in Fe of left vertical grid line
    grid_start_y = 0;  %Vertical position in Fe of top horizontal grid line (max y-coordinate)
    
    grid_x_posn = grid_start_x:grid_space_x:grid_start_x+map_size_x;
    grid_y_posn = grid_start_y:grid_space_y:grid_start_y+map_size_y;
    N_cell_x = length(grid_x_posn)-1;
    N_cell_y = length(grid_y_posn)-1;
    
    %r_max = 5; %max range in meters
    %not used yet
    
    %create corresponding grids
    %masterGrid = occupancyGrid; % grid that will be the whole room map
    %scanToAdd = occupancyGrid;  % grid that will store temporary scans
    
    Loc_points = [25,25];%setup horizontal matrix to store localization data
    
    E_Map = zeros(N_cell_y,N_cell_x); %create emptiness and occupancy matrix
    O_Map = zeros(N_cell_y,N_cell_x);
    
    P_Map = zeros(N_cell_y,N_cell_x);%create map to hold positions traveled
    
    
    step_per_cell = 3;       %Range step depends on grid size
    r_step = min(grid_space_x,grid_space_y)/step_per_cell; %Stepsize to take along measurement ray

	%%
	K_N_d = 640; % Number of depth pixels
	K_TFOV = 57.5;   % Degrees
	K_b_scale = 2*tand(K_TFOV/2)/K_N_d; % This scales pixels to tangent of bearing
	K_b_true = atan(K_b_scale*[(K_N_d-1)/2:-1:-(K_N_d-1)/2]); % Kinect bearing angle (degrees) for each pixel
	
	%% 
	
    %initialize_hardware

% take initial 9150 bearing
    %Pull the orientation of the Kinect from the 9150. Roll, pitch, yaw are
    %saved into orientation as a 1x3 matrix
    orientation = curr_mpu9150;
    
    %Yaw is pulled from orientation variable and saved into yaw variable.
    startYaw = orientation(1,3);
    
    %note: starting yaw is used to orient the map based on the
    %initialization. Starting position is always down on the map
	
    
%% define BUG starting position. [x, y, bearing]
	xv_init = [25;25;startYaw]; 
    xv_true = xv_init;
    P_Map(25,25) = 1;
    roundingError = zeros(1:2);
% Now that we have everything set up, we can go through running the system
