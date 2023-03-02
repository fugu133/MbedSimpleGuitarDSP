

fs = 48000
N = 4096*8
fi = 440;

R = 10;      // 圧縮比
T = -12;     // 閾値[dB]
W = 0;       // knee幅[dB]
M = 0;       // Gain[dB]
ta = 0;   //アタックタイム
tr = 0; //リリースタイム
ar = exp(-log(9)/(fs*ta))
rr = exp(-log(9)/(fs*tr))

// 入力信号
t = 0:1/fs:10
n = size(t)(2);
x = sin(2*%pi*fi*t);
y = zeros(x);

// dB Convert
xdb = 20*log10(abs(x))

/* Gain Computer */
//Static Characterristic
xsc = zeros(xdb);

for i = 1:n
    if xdb(i) < (T-W/2) then
        xsc(i) = xdb(i);
    elseif xdb(i) > (T + W/2) then
        xsc(i) = T + (xdb(i) - T)/R;
    else
        xsc(i) = xdb(i) + (1/R - 1)*(xdb(i) - T + W/2)^2 / (2*W);
    end
end
gc = xsc - xdb; // computed gain

/* Gain smoothing */
//Level detect
gs = zeros(gc);
gs_after = 0

for i = 1:n
    if gc(i) <= gs_after then
        gs(i) = ar*gs_after + (1-ar)*gc(i)
    else
        gs(i) = rr*gs_after + (1-rr)*gc(i)
    end
end


/* Makeup Gain */
gm = gs + M;

/* Linear Convert */
y = 10^(gm/20).*x;

scf
plot2d(t, x, 1);
plot2d(t, y, 2);
legend(["Input signal", "Output Signal"], "font_size", 3)
xlabel("Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)
a=gca();
a.data_bounds(:,1) = [0;0.01];

