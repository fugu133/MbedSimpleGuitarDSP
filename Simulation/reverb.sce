xdel

fs = 48000;
n = fs + 1

x = zeros(1,n);       // 入力
x(2401) = 1;
sn = size(0:1/fs:0.3)(2)
for i=1:sn
    x(i) = sin(2*%pi*60 * (i-1)/fs);
end
y = zeros(x);         //出力
t = 0:1/fs:1;

volume = 2;
d_time = 100;           //ディレイタイム(ms)
repeat = 0.7;          //繰り返し数
rn = fs*d_time/1000    //リングバッファサイズ
d_line = zeros(1, rn); //リングバッファ
d_line_idx = 0;        // リングバッファ位置

for i = 1:n
    in_sig = x(i) * 0.5;
    re_sig = d_line(d_line_idx + 1) * repeat;
    d_line(d_line_idx + 1) = in_sig + re_sig;
    y(i) =  d_line(d_line_idx + 1) * volume;
    d_line_idx = modulo(d_line_idx + 1, rn);
end

subplot(211);
plot2d(t, x);
xlabel("Time [s]")
ylabel("Amplitude")
title("Input signal")
subplot(212);
plot2d(t, y);
xlabel("Time [s]")
ylabel("Amplitude")
title("Output signal")
