#!/usr/bin/python3.7

import matplotlib.pyplot as plt
import numpy as np

import sys, os, getopt

A = "abs,acos:arccos,asin:arcsin,atan:arctan,atan2:arctan2".split(',')
B = "ceil,cos,cosh,degrees,e,exp,fabs,floor,fmod,frexp,hypot".split(',')
C = "ldexp,log,log10,modf,pi,radians,sin,sinh,sqrt,tan,tanh".split(',')
maths_expr = A+B+C


# TODO: Write my own commandline for plotting
# https://github.com/drdrang/simple-plotting


def safe_eval(expr, locals=[]):
    def pair(k):
        if ':' in k:
            [key, value] = k.split(':')
        else:
            [key, value] = [k,k]
        return (key, np.__dict__[value]);
    safe_locals = dict([pair(k) for k in maths_expr]);

    for k in locals:
        safe_locals[k] = locals[k];

    return eval(expr, {"__builtins__":None}, safe_locals)

def plot(expr, interval):
    x = np.linspace(interval[0], interval[1], 1000);
    plt.plot(x, safe_eval(expr, {'x': x}))
    plt.show()
 
def  plot3d(expr, interval):
    #dpi = 70;
    #plt.figure(figsize=(400/dpi, 300/dpi), dpi=dpi)
    plt.figure()
    ax = plt.axes(projection='3d')

    #plt.title(title, fontname='Helvetica')

    #xr = ranges.get('xrange', '[-1:1]')[1:-1].split(':')
    #yr = ranges.get('yrange', '[-1:1]')[1:-1].split(':')
    

    x = np.linspace(float(safe_eval(xr[0])),float(safe_eval(xr[1])),101);
    y = np.linspace(float(safe_eval(yr[0])),float(safe_eval(yr[1])),101);
    x, y = np.meshgrid(x,y)
    r = np.sqrt(x**2 + y**2)
    theta = np.arctan2(x,y);

    for (i, exp) in enumerate(exprs):
        ls = line_style[i] if i < len(line_style) else {};
        ax.plot_surface(x, y, safe_eval(exp, {'x': x, 'y':y, 'r':r, 'theta':theta}), cmap='viridis');

    plt.savefig('tmp/splot.png');
    

# TODO: plot to png
def main(argv):
    interval = [-1,1]
    threeD=False
    
    try:
        opts, args = getopt.getopt(argv, "hi:", ["interval"]);
    except getopt.GetoptError:
        helpmessage()
    for opt, arg in opts:
        if opt == '-h': helpmessage();
        if opt == '-3d': threeD=True;
        elif opt in ('-i', '--interval'):
            interval = safe_eval(arg);
    if threeD:
        plot3d(args[0], interval)
    else:
        plot(args[0], interval)


if __name__ == "__main__":
	main(sys.argv[1:])
