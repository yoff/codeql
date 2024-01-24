def passThrough(x):
    return x

def tackOn(x, l):
    return [(x, e) for e in l]

def readFoo(x):
    return x.foo

def writeFoo(x, y):
    x.foo = y