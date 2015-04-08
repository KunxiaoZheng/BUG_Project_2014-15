function [position, roundingError] = howMuch(pot_val, left_vel, right_vel, t, xv_true, roundingError)
%%this function is used to get the x-y displacement based on the pot-value,
%left wheel and right wheel velocities, and the time


before_bearing = xv_true(3); %save bearing angle before movement occured

%% untested calculations

%velocitites of back wheels come in as mm/ms
left = left_vel*100; %convert velocity of wheels to cm/s
right = right_vel*100;


%%
%instantaneous forward velocity
Sv = (left+right)/2;

%instantateous angular velocity
w = (right-left)/(43.2)

%potentiometer value is between 0 and 1024
%convert to angle (in radians)
pot = (pot_val *pi)/1024;
pot = pi/2 - pot 

delta = 1:2; %setup 1x2 matrix for delta x and delta y

if(abs(pot) > 0.1 && left - right ~= 0)
    %disp('sig');
    C = Sv/w; 
    delta = [C*sin(w*t); C*(1-cos(w*t))]
else
    %disp('not sig');
    delta = [Sv*t; 0]
end
if(before_bearing+pi >3*pi/2)
    psi =pi-before_bearing+(pi/2)
else
    psi =pi/2 - (before_bearing +pi) 
end
position = zeros(2,2);
position = [cos(psi) -sin(psi); sin(psi) cos(psi)];
position = position * delta
position(2)=-(position(2));

%take final displacement, and convert it to number of cells moved
roundingError(1) = roundingError(1) + mod(position(1), 25);
roundingError(2) = roundingError(2) + mod(position(2), 25);

position = ceil(position ./ 25);

if(roundingError(1) >=25)
    position(1) = position(1) + 1;
    roundingError(1) = roundingError(1) - 25;
end
if(roundingError(2) >=25)
    position(2) = position(2) + 1;
    roundingError(2) = roundingError(2) - 25;
end




