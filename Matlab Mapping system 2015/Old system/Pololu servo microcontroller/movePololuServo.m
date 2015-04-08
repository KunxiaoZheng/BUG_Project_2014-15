function movePololuServo(servo, port, channel, servo_setting, device)
%MOVEPOLOLUSERVO Control an attached Pololu Maestro Servo Controller
% Given a channel (servo number), servo setting (in 1/4 micro seconds) and
% serial port name (string), sends a command to the Pololu Servo controller.
%
% If multiple controllers are daisy chained on the same serial line, the
% device parameter can be used to select which device to talk to
% (defaults to 12).
%
% Note that valid Serial ports can sometimes be found using
% instrfindall() (or by looking in /dev/cu.* on *nix or OSX machines)
%
% port - The Serial Port. Note on Linux and OSX the controller will
% create two virtual serial ports, e.g. /dev/cu.usbmodem00234567
% and /dev/cu.usbmodem00234563 - you must select the one with a
% lower numerical number.
% channel - The channel of interest
% servo_setting - The servo pulse width setting in 1/4 micro seconds
% device - The Pololu controller device ID. Defaults to 12
%
% Example usage:
% Linux/OSX: movePololuServo('/dev/cu.usbmodem00234567', 0, 6120);
% Windows: movePololuServo('\\.\COM6', 0, 6120);
% Using a SpringRC Continuous Rotation Servo, a setting of 6120 corresponds
% to about 2RPM, while 6000 is 0. Anything below 6000 runs the servo in
% reverse.
%
% Finally, note that before using this script, the controller must be
% modified using the Pololu Servo Controller Software to be in USB Dual
% Port mode.
%
% This code based on discussions at
% http://forum.pololu.com/viewtopic.php?f=16&t=3246
    
    % Device number is 12 by default
    if(nargin == 4)
        device = 12;
    end
    
    % Initialize
    %ser1 = serial(port);
    %set(ser1, 'InputBufferSize', 2048);
    %set(ser1, 'BaudRate', 9600);
    %set(ser1, 'DataBits', 8);
    %set(ser1, 'Parity', 'none');
    %set(ser1, 'StopBits', 1);
    %fopen(ser1);
    ser1 = servo;
    % Format servo command
    lower = bin2dec(regexprep(mat2str(fliplr(bitget(6120, 1:7))), '[^\w'']', ''));
    upper = bin2dec(regexprep(mat2str(fliplr(bitget(servo_setting, 8:14))), '[^\w'']', ''));
    
    
    
    
    
    % Advanced Serial Protocol
    % 0xAA = 170
    % 4 = action (set target)
    command = [170, device, 4, channel, lower, upper];
        
    % Simple Serial Protocol
    % 0x84 = 132
    %command = [132, channel, lower, upper];
    
    % Send the command
    fwrite(ser1, command);
    
    % Clean up - NB: On some Mac MATLAB versions, fclose will crash MATLAB
    % If so, you'll need to modify this function to pass in a serial
    % instance, and then never close the port in your own code
    %fclose(ser1);
    %delete(ser1);
end