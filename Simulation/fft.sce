clf;
fs = 48000
fi = 440;
fc = 10000
N = 4096*4
p = 16
gain = 100;

t = 0:1/fs:(1/fs)*(N-1)
x = sin(2*%pi*fi*t);
y = (2/%pi) * atan(gain*x);

X = fft(x)
Y = fft(y)
f = fs*(0:(N/2))/N;
n = size(f,'*')

X = abs(X(1:n));
X = X/max(X)

Y = abs(Y(1:n))
Y = Y/max(Y)

scf();
plot2d(t,x,1)
plot2d(t,y,2);
xlabel("Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)
legend(["Input signal", "Output signal"], "font_size", 3)
a=gca();
a.data_bounds(:,1) = [0;0.01];


scf();
//subplot(211);
//title("Input signal", "font_size", 3)
//plot2d(f,X,2)
//xlabel("Frequency [Hz]", "font_size", 3)
//ylabel("Amplitude", "font_size", 3)
//a=gca();
//a.data_bounds(:,1) = [0;10e3];

//title("Output signal", "font_size", 3)
plot2d(f,Y,2);
xlabel("Frequency [Hz]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)
a=gca();
a.data_bounds(:,1) = [0;10e3];
