function [O_Map, E_Map,Loc_points] = MatrixMap(averageRow,K_b_true,xv_true,r_step,grid_x_posn,grid_y_posn,N_cell_x,N_cell_y,E_Map,O_Map,start_yaw,Loc_points)
%create both an emptiness map and an occupancy map based on the given
%average row data
%

K_depth = averageRow ./ 250; %take kinect values from mm to 10x cm so we have visible map change
%if we don't do this, the map will update up to 3 cells per scan. This
%will not be enough of a visual to show anyone a the room scan
%each cell is 0.25 m 


%K_depth(1:5:end);  %take every 5th value, since we do not need all of
%the resolution
K_r_true = K_depth ./ cos(K_b_true); %get the actual distance to the object at each pixel(Adjacent/cos(angle))

xv_est = xv_true; %keep track of the position. The BUG has moved, so the true
%position is now an estimated location
r_est = K_r_true; %estimated actual distances from averageRow
b_est = K_b_true; %estimated Kinect bearing angle per pixel 


[Local_E_map,Local_O_map,point_1,point_2,point_3] = compute_local_maps(xv_est,b_est,r_est,r_step,grid_x_posn,grid_y_posn,N_cell_x,N_cell_y,start_yaw);
%use averageRow values to compute emptiness and occupied maps. 
%returns emptiness map, occupied map and up to 3 points for later localization
%and object tracking

E_Map = E_Map + Local_E_map; %add the returned local maps to the global maps
O_Map = O_Map + Local_O_map; 

%localization
Loc_points = horzcat(Loc_points, point_1);
Loc_points = horzcat(Loc_points, point_2);
Loc_points = horzcat(Loc_points, point_3);

%display maps

max_E_map = max(max(E_Map));  % Used to scale images
min_E_map = min(min(E_Map));
max_O_map = max(max(O_Map));
min_O_map = min(min(O_Map));

%displays the emptiness map
% figure
% E_map_h=image(256*((E_Map-min_E_map)/(max_E_map-min_E_map)));
% colormap(gray(256));
% title('Emptiness Support Map');
% xlabel('X Cells');
% ylabel('Y Cells');
 %
%displays the occupancy map
% figure
% O_map_h=image(256*((O_Map-min_O_map)/(max_O_map-min_O_map)));
% colormap(gray(256));
% title('Occupied Support Map');
% xlabel('X Cells');
% ylabel('Y Cells');
 
%
% use logarithmic scale to see occupied support more clearly
%
%Log_O = log10(O_Map+1);
%max_LGO_map = max(max(Log_O));
%min_LGO_map = min(min(Log_O));
% figure;
% LO_map_h = image(256*((Log_O-min_LGO_map)/(max_LGO_map-min_LGO_map)));
% colormap(gray(256));
% title('Log10 of Occupied Support Map');
% xlabel('X Cells');
% ylabel('Y Cells');
 
 
 

%
% Use logarithmic scale to see emptyness support more clearly.
%
log_Global_E_map = log10(E_Map+1);
max_LGE_map = max(max(log_Global_E_map));
min_LGE_map = min(min(log_Global_E_map));
this = figure;
LE_map_h = image(256*((log_Global_E_map-min_LGE_map)/(max_LGE_map-min_LGE_map)));
colormap(gray(256));
xlabel('X Cells');
ylabel('Y Cells');
%imwrite(256*(log_Global_E_map),gray(256),'LogMap.jpg','jpg');
%save the log map for later use with the control system
saveas(this,'LogMap.jpg');
title('Log10 of Emptiness Support Map');

