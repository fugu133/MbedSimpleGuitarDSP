clf

// Static Parameter
fs = 48000;
fmax = 22000;
k = 1:31
fc = fmax*2^((k-31)/3)
gain = zeros(fc)

stage = size(fc)(2);
N = 1024*8
Q = 3*sqrt(2);
t = 0:1/fs:(1/fs)*(N-1)
in = 0.5*sin(2*%pi*fc(8)*t) + 0.05*sin(2*%pi*fc(18)*t) + 0.05*sin(2*%pi*fc(25)*t);
//in = zeros(t)
//in(1) = 1
gain(8) = 6;
gain(18) = -24;
gain(25) = -24

x = in;
x_delay = zeros(stage,2);
u_delay = zeros(x_delay);

// Active Parameter
mu  = 10^(gain/20)
theta0 = 2*%pi*fc/fs

A = tan(theta0/(2*Q))
B = cos(theta0)
C = 4 ./ (1+mu)
D = (mu - 1)
beta = 0.5*(1 - C.*A) ./ (1 + C.*A)
gamma = (0.5 + beta) .* B
alpha = (0.5 - beta) * 0.5

s = 10
y = zeros(x)
for s = 1:stage
    for i = 1:N
        u = 2*(alpha(s)*(x(i)-x_delay(s,2)) + gamma(s)*u_delay(s, 1) - beta(s)*u_delay(s, 2))
        
        x_delay(s,2) = x_delay(s,1)
        x_delay(s,1) = x(i)
        u_delay(s,2) = u_delay(s,1)
        u_delay(s,1) = u
        
        y(i) = x(i) + D(s)*u;
    end
    x = y
end

plot2d(t, in, 1);
plot2d(t, y, 2);
legend(["Input signal", "Output Signal"], "font_size", 3)
xlabel("Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)
a=gca();
a.data_bounds(:,1) = [0;0.05];

/*
Y = fft(y);
f = fs*(0:(N/2))/N;
n = size(f)(2);
scf();
plot2d('ln',f,20*log10(abs(Y(1:n))),2)
xlabel("Frequency [s]", "font_size", 3)
ylabel("Gain [dB]", "font_size", 3)

a=gca();
a.data_bounds(:,1) = [1e1;2e4];
*/
