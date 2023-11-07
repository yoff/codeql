# Here we test the cases where a variable is being captured by an object.

# All functions starting with "test_" should run and execute `print("OK")` exactly once.
# This can be checked by running validTest.py.

import sys
import os

sys.path.append(os.path.dirname(os.path.dirname((__file__))))
from testlib import expects

# These are defined so that we can evaluate the test code.
NONSOURCE = "not a source"
SOURCE = "source"

def is_source(x):
    return x == "source" or x == b"source" or x == 42 or x == 42.0 or x == 42j


def SINK(x):
    if is_source(x):
        print("OK")
    else:
        print("Unexpected flow", x)


def SINK_F(x):
    if is_source(x):
        print("Unexpected flow", x)
    else:
        print("OK")

# Actual tests

def object_in(tainted):
    class Reader:
        def get(self):
            return tainted
        
    r = Reader()
    SINK(r.get()) # $ MISSING: captured

def test_object_in():
    object_in(SOURCE)

def object_out():
    written = { "cell": NONSOURCE }

    class Writer:
        def set(self):
            written["cell"] = SOURCE

    w = Writer()
    w.set()
    SINK(written["cell"]) # $ MISSING: captured

def test_object_out():
    object_out()

def object_through(tainted):
    written = { "cell": NONSOURCE }

    class Writer:
        def set(self):
            written["cell"] = tainted

    w = Writer()
    w.set()
    SINK(written["cell"]) # $ MISSING: captured

def test_object_through():
    object_through(SOURCE)
