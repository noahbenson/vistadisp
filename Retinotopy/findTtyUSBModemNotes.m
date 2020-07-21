
s = serial('/dev/tty.usbmodem123451','BaudRate',57600);
fopen(s);
fprintf(s,'[t]');

% ls -lh /dev/tty.usb* to find the modem
