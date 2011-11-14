import serial
import sys

def main():
    s = serial.Serial('/dev/ttyACM1', 115200, timeout=2)
    print("Waiting for boot signal")
    print(s.read())
    print("Writing sway command")
    s.write("".join(map(chr, [0x55, 0x0, 0x3, 0, 2, 72])))
    print(s.read())
    print("Reading motor encoders")
    s.write("".join(map(chr, [0x55, 0x1, 0x12])))
    print(["0x%.02x " % ord(x) for x in s.read(12)])

if __name__ == '__main__':
    sys.exit(main())