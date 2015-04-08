%INITIALIZESERVO.M Initializing the servo microcontroller serial port

%Setting up the serial connection
ser1 = serial('COM6');
set(ser1, 'InputBufferSize', 2048);
set(ser1, 'BaudRate', 9600);
set(ser1, 'DataBits', 8);
set(ser1, 'Parity', 'none');
set(ser1, 'StopBits', 1);

%Opens the serial port, allowing the controller to be able to receive
%commands
fopen(ser1);


%Set the speed of the servo motor
%0x87 = 135
%speed lower bit = 0100 = 4
%speed higher bit = 0001 = 1
%Command format: 0x87, channel #, speed low bits, speed high bits

command = [135, 0, 10, 0];

%Writes the command to the servo controller.
fwrite(ser1, command);