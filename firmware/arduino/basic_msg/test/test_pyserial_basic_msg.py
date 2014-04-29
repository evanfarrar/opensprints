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
            self.assertEqual('basic-1.01\n', result)

            # test setting length
            # in the basic-1 way.
            sio.write(unicode("l" + chr(11) + chr(0) + '\r'))
            sio.flush()
            expect = u'OK 11\n'
            actual = sio.read()
            self.assertEqual(expect, actual)

            # test setting length again
            # in the basic-1 way.
            sio.write(unicode("l23\r"))
            sio.flush()
            # 50 + 51 * 256 = 13106
            expect = u'OK 13106\n'
            actual = sio.read()
            self.assertEqual(expect, actual)

            # test setting length again
            # in the basic-1.01 way.
            sio.write(unicode("l23"))
            sio.flush()
            # 50 + 51 * 256 = 13106
            expect = u'OK 13106\n'
            actual = sio.read()
            self.assertEqual(expect, actual)

            # Test version again
            sio.write(unicode("v"))
            sio.flush()
            result = sio.read()
            self.assertEqual('basic-1.01\n', result)
