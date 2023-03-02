xdel

fs = 48000;
t = 0:1/fs:1;
n = size(t)(2)

x = zeros(1,n);       // 入力
sn = size(0:1/fs:0.05)(2)
for i=1:sn
    x(i) = sin(2*%pi*50*(i-1)/fs);
end

y = zeros(x);         //出力

volume = 2;
d_time = 30;     //ディレイタイム(ms)
mix = 0.6;        //ミックス
feedback = -0.8;
rn = fs*d_time/1000    //リングバッファサイズ
d_line = zeros(1, rn); //リングバッファ
d_line_idx = 0;        // リングバッファ位置

for i = 1:n
    in_sig = x(i) * 0.5;
    fb_sig = d_line(d_line_idx + 1);
    d_line(d_line_idx + 1) = in_sig + fb_sig*feedback;
    y(i) =  (in_sig + fb_sig * mix) * volume;
    d_line_idx = modulo(d_line_idx + 1, rn);
end

subplot(211)
plot2d(t, x, 1);
xlabel("Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)

a=gca();
a.data_bounds(:,1) = [0;0.7];

subplot(212)
plot2d(t, y, 2);
xlabel("Time [s]", "font_size", 3)
ylabel("Amplitude", "font_size", 3)

a=gca();
a.data_bounds(:,1) = [0;0.7];
