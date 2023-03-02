clf();
fs = 48000
N = 4096
t = 0:1/fs:5;
w = 5
t = 0:1/fs:(1/fs)*(N-1)

x = -10:0.01:10
y = 2*atan(x)/%pi
x = x/10
plot2d(x,x,1);
plot2d(x,y,2);
xlabel(" x amplitude", "font_size", 3)
ylabel("y amplitude", "font_size", 3)
legend(["Clean", "Distortion"], "font_size", 3)
        

scf();
y = zeros(t);
z = sin(t);      
plot2d(t,z,1)
y = (2/%pi) * atan(z*i*gain_w);
plot2d(t, y, 2); 

