# std
from contextlib import contextmanager
import io
import time
import unittest

# vendor
import serial


@contextmanager
def open_serial_io(path=None):
    try:
        path = path or '/dev/tty.usbserial-A6008sxN'
        ser = serial.Serial(path, 115200, timeout=1)
        time.sleep(2)
        sio = io.TextIOWrapper(io.BufferedRWPair(ser, ser))
        yield sio
    finally:
        ser.close()


class Test(unittest.TestCase):

    def test_stuff(self):
        with open_serial_io() as sio:

            # Test version
            sio.write(unicode("v"))
            sio.flush()
            result = sio.read()
            self.assertEqual('basic-1\n', result)

            # Test version again
            sio.write(unicode("v"))
            sio.flush()
            result = sio.read()
            self.assertEqual('basic-1\n', result)
