clf
clf
fs = 48000
N = 4096*8
fi = 100;

// コンプレッサパラメータ
p = 100 //圧縮比
vt = 0.2 //閾値
ta = 1/1000 //アタックタイム
tr = 0.1/1000 //リリースタイム
h1 = exp(-1/(fs*ta + 1));
h0 =1 - h1;
r1 = exp(-1/(fs*tr + 1));
r0 = 1- r1;

// 入力信号
t = 0:1/fs:N/fs
n = size(t)(2);
x = sin(2*%pi*fi*t)// + 0.5*sin(2*%pi*2.5*fi*t)
x = x / max(x)
y = zeros(x);

// gain block
G = zeros(x);
G(1) = 1;
for i = 1:n
    amp = abs(x(i))
    if amp >= vt then
        G(i) = vt^((p-1)/p)*amp^((1-p)/p)
    else G(i) = 1;
    end    
end

Gafter = 1;
C1 = 0
C0 = 0
for i = 1:n

    if G(i) < Gafter then
        C0 = h0
        C1 = h1
    else 
        C0 = r0
        C1 = r1
    end
    G(i) = G(i)*C0 + Gafter*C1
    Gafter = G(i)
end

y = G.*x

plot2d(t, x, 1);
plot2d(t, y, 2);
legend(["Input signal", "Output Signal"], "font_size", 3)
xlabel(" Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)

a=gca();
a.data_bounds(:,1) = [0;0.5];



X = fft(x)
Y = fft(y)
f = fs*(0:(N/2))/N;
n = size(f,'*')

X = abs(X(1:n));
X = 20*log10(X)

Y = abs(Y(1:n))
Y = 20*log10(Y)

scf();
subplot(211);
title("Input signal")
plot2d(f,X-max(X))
xlabel("Frequency [Hz]")
ylabel("Amplitude [dB]")

subplot(212);
title("Output signal")
plot2d(f,Y-max(X));
xlabel("Frequency [Hz]")
ylabel("Amplitude [dB]")
