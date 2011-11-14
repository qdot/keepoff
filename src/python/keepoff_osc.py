import serial
import sys
import math
from OSC import OSCServer

s = serial.Serial('/dev/ttyACM1', 115200)

# this method of reporting timeouts only works by convention
# that before calling handle_request() field .timed_out is 
# set to False
def handle_timeout(self):
    self.timed_out = True

def rotate_callback(path, tags, args, source):
    s.write("".join(map(chr, [0x55, 0x0, 0x3, 4, int(args[0]), 160])))
    print(s.read())
    print math.floor(args[0])

def bf_callback(path, tags, args, source):
    s.write("".join(map(chr, [0x55, 0x0, 0x3, 2, int(args[0]), 160])))
    print(s.read())
    print math.floor(args[0])

def quit_callback(path, tags, args, source):
    # don't do this at home (or it'll quit blender)
    global run
    run = False

def main():
    print("Waiting for boot signal")
    print(s.read())
    print("Writing sway command")
    s.write("".join(map(chr, [0x55, 0x0, 0x3, 0, 2, 72])))
    print(s.read())
    # print("Reading motor encoders")
    # s.write("".join(map(chr, [0x55, 0x1, 0x12])))
    # print(["0x%.02x " % ord(x) for x in s.read(12)])
    server = OSCServer( ("192.168.123.75", 10000) )
    server.timeout = 0
    # funny python's way to add a method to an instance of a class
    import types
    server.handle_timeout = types.MethodType(handle_timeout, server)

    server.addMsgHandler( "/rotate", rotate_callback )
    server.addMsgHandler( "/bf", bf_callback )
    
    try:
        while 1:
            server.handle_request()
    except KeyboardInterrupt:
        pass


    server.close()

if __name__ == '__main__':
    sys.exit(main())