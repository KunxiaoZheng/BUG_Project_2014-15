function [xv_true,Loc_points, roundingError, P_Map] = move_BUG(pot_val, left_vel, right_vel, t, xv_true,Loc_points, start_yaw, roundingError, P_Map)
%MOVE_BUG move the BUG position based on the given angle and distance
%traveled

%pot_val is potentiometer value input from BUG
%left_vel is left wheel velocity input from BUG
%right_vel is right wheel velocity input from BUG
%t is the time taken for the movement and is an input from the BUG

%xv_true is the true position of the BUG (y, x)
%Loc_points are the localization points of the system

%%
[position, roundingError] = howMuch(pot_val, left_vel, right_vel, t, xv_true, roundingError)


%x-y displacement based on BUG bearing at the start of the movement

%With the Kinect centered, the new bearing should be the current 9150 angle
%orientation = curr_mpu9150;

%xv_true(3) = orientation(1,3); %store new bearing angle

%%
%%move based on x-y coordinates (for testing)
%position = [5 0];



%% to test
%code to follow the path of the BUG
%Loc_points = Loc_points + position; %store point in location matrix

%step through position map, and store a zig-zag route from 
%position -1 to current position
while (abs(position(1)) >= 0 && abs(position(2)) >=0) 
    if(position(1) > 0)
        position(1) = position(1) -1;
        xv_true(2) = xv_true(2) +1;
        P_Map(xv_true(1),xv_true(2)) = P_Map(xv_true(1),xv_true(2)) +5;
    elseif(position(1) < 0)
        position(1) = position(1) +1;
        xv_true(2) = xv_true(2) -1;
        P_Map(xv_true(1),xv_true(2)) = P_Map(xv_true(1),xv_true(2)) +5;
    end
    if(position(2) > 0)
        position(2) = position(2) -1;
        xv_true(1) = xv_true(1) +1;
        P_Map(xv_true(1),xv_true(2)) = P_Map(xv_true(1),xv_true(2)) +5;
    elseif(position(2) < 0)
        position(2) = position(2) +1;
        xv_true(1) = xv_true(1) -1;
        P_Map(xv_true(1),xv_true(2)) = P_Map(xv_true(1),xv_true(2)) +5;
    end
    if(position(1) ==0 && position(2) == 0)
        %disp('done');
        break;
    end
end

%add 10 to current position to emphasize movement locations
if(position(1) == 0 && position(2) ==0)
    P_Map(xv_true(1),xv_true(2)) = P_Map(xv_true(1),xv_true(2)) +10;
end

figure, image(P_Map*10);


