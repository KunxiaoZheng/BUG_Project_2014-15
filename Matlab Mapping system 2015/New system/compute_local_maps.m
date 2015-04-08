function [Local_E_map,Local_O_map,point_1,point_2,point_3] = compute_local_maps(xv_est,b_est,r_est,r_step,grid_x_posn,grid_y_posn,N_col,N_row,start_yaw);
%
%[Local_E_map,Local_O_map] = compute_local_maps(xv_est,b_est,r_est,r_status,r_max,r_step,grid_x_posn,grid_y_posn);
%
% Generates local maps based on the averageRow returned by the kinect.
% Cells are returned as a Sum of Empty or Occupied support
%

%initialize variables
Nr = 0; %#ok<*NASGU>
ray = 0;
r_test = 0;
Nb = length(b_est)-1;
v_posn = xv_est(1:2);
v_heading = xv_est(3);
%create localization points for later use
point_1 = [0,0];
point_2 = [0,0];
point_3 = [0,0];
%create variable to store states of the points
l_check = [0,0,0];

Local_E_map = zeros(N_row,N_col); % Initialize local emptiness map with no information
Local_O_map = zeros(N_row,N_col); % Initialize local occupied map with no information

%grab orientation data from the 9150
orientation = curr_mpu9150;
curr_yaw = orientation(1,3)
%correct for initial yaw angle
est_yaw = curr_yaw - start_yaw;
%
% Step through each bearing and range measurement
%
for i=1:Nb,
    if(r_est(i)~=0) %if averaged value does not equal 0.
        r_test = [0:r_step:r_est(i),r_est(i)];   % Define testing distances out to measured range, force measured range
        Nr = length(r_test);
        ray = [cos(v_heading + b_est(i) + est_yaw);sin(v_heading + b_est(i) + est_yaw)];
          %
          %Check for full cell within map detected at this bearing
          %
          end_test_point = v_posn + (r_test(Nr)*ray);
          %use get_cell to determine if the cell is in the local maps
          [end_row,end_col,success] = get_cell(end_test_point(1),end_test_point(2),grid_x_posn,grid_y_posn);
          %returns row and column of given cell, as well as success
		  if(~success), %if success is 0, then the point is outside of the local maps, so return an error
              v_posn
              end_test_point
              r_test(Nr)
            error('End cell outside of map');
          end;
          
          Local_O_map(end_row,end_col) = Local_O_map(end_row,end_col) + 1;
          
           
          %
          % Start with cell containing vehicle, and this cell gets E support
          %vehicle is 85cm long x 60cm wide
          %each cell is 
          %
          start_test_point = v_posn;
          [prev_row,prev_col,init_success] = get_cell(start_test_point(1),start_test_point(2),grid_x_posn,grid_y_posn);
          if (~init_success),
            error('Initial vehicle pose outside of Maps');
          end;
          Local_E_map(prev_row,prev_col) = Local_E_map(prev_row,prev_col) + 1;
          %
          % Now have to fill empty cells from vehicle position to end of ray, not
          % for end cell, and do not duplicate cell counts!
          %
          for ri = 1:Nr,
            test_point = v_posn + r_test(ri)*ray;
            [this_row,this_col,success] = get_cell(test_point(1),test_point(2),grid_x_posn,grid_y_posn);
            if (~success),                   % Check if outside of map
              error('Test ray outside of Maps');
            end;
            %
            if ((this_row ~= prev_row) || (this_col ~= prev_col)),  % New cell
              if ((this_row ~= end_row) || (this_col ~= end_col)), %Except last cell
                %disp('adding emptiness support to cell')
                Local_E_map(this_row,this_col) = Local_E_map(this_row,this_col) + 1;
                %
%               else 
% 				  %localization code
% 				  %if the occupied spaces are spread out enough, use them as localization points 
%					%This code does not really work. You will have to look into better ways to do this.
%					%but the overall idea was to take objects seen in the room, and track them as the BUG moves.
%					%maybe even move the BUG's theoretical position based on these tracked objects.
% 		  
%                    if(i<(Nb/2) && l_check(1)~=1), %if first half of average row
%                        point_1 = [end_col,end_row]; %set point 1 to the end cell (does not actually grab end cell... no clue why)
%                        l_check(1) = 1;
%                        %disp('point_1 set to:');
%                        %disp(point_1);
% 
%                    elseif(i>(Nb/2) && l_check(2)~=1), %if second half of average row
%                       point_2 = [end_col,end_row]; % set point 2 to the end cell (seems to work. continue testing)
%                       l_check(2) = 1;
%                       %disp('point_2 set to:');
%                       %disp(point_2);
%                   end;
              end;
              prev_row = this_row;
              prev_col = this_col;
            end;
          end; %for ri = 1:Nr
    end; %if averaged value equals 0
end; %for i = 1:Nb
end

