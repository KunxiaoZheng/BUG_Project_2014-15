function [B] = curr_mpu9150()
    %
    %This function reads in from curr_9150_data.txt; this file recieves the
    % values from the 9150.exe
    %[input] = N/A 
    %[output] = most current euler angle orrientation representation

    %path = 'D:\Google Drive\Fourth Year Project (MIPS)\Occupancy Grid System\Occupancy Grid System code\9150\curr_9150_data.txt';
    %path = 'C:\Users\jeffchapman-admin\Desktop\Occupancy Grid System\Occupancy Grid System code\9150\curr_9150_data.txt';
    path = 'C:\Users\jimmyzheng-admin\Desktop\Mapping System\Occupancy Grid System code\9150\curr_9150_data.txt';
    fid=fopen(path);
    num = numel(fscanf(fid, '%g %g %g %g', [1 inf]));
    frewind(fid);
    num = num/4;
    A = fscanf(fid, '%g %g %g %g', [4 num]);
    fclose(fid);
    A = convert_quat_to_rpy(A, num);
    B = last_row(A);
    
end

function [mod_data] = convert_quat_to_rpy(data, num)

    mod_data = [num,3];
    for loop = 1:1:num

        %roll
         A = atan2(2.*(data(1,loop).*data(2,loop)+data(3,loop).*data(4,loop)),1-2.*(data(2,loop).^2+data(3,loop).^2));
         mod_data(loop,1)=A;%.*(180./pi);
        %pitch
         B = asin(2.*(data(1,loop).*data(3,loop)-data(2,loop).*data(4,loop)));
         mod_data(loop,2)=B;%.*(180./pi);
        %yaw
         C = atan2(2.*(data(1,loop).*data(4,loop)+data(3,loop).*data(2,loop)),1-2.*(data(3,loop).^2+data(4,loop).^2));
         mod_data(loop,3)=C;%.*(180./pi);
    end
end

function [output]=last_row(input)
    %outputs the last row of a matrix
    output = input(end,:);
    
end