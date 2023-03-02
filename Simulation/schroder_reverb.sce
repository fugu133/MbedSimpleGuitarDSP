clf;
clc;

// Static Parameter
fs = 48000;
t = 0:1/fs:2;
N = size(t)(2);
in = zeros(t);
//in(2401) = 1; // Impulse input
in(1) = 1;
/*sn = size(0:1/fs:0.1)(2)
for i=1:sn
    in(i) = sin(2*%pi*60 * (i-1)/fs);
end:*/

// Reverb Parameter
volume = 1
pre_d_time = 10 //ms
decay = 2
mu1 = 1
mu2 = 1
mu3 = 1

// Multi Tap Delay
mtd_d_time_max = 100;
mtd_d_n = round(mtd_d_time_max*fs/1000);
mtd_d_time = 10:5:50;
mtd_tap_idx = mtd_d_n - round(mtd_d_time*fs/1000);
mtd_d_idx = 0;
mtd_gain = 0.9:-0.1:0.1;

mtd_pre_d_time = pre_d_time;
mtd_pre_tap_idx = mtd_d_n - round(mtd_pre_d_time*fs/1000);

mtd_d_l = zeros(in);

// Comb Filter Parameter
cf_d_time = [39.85 36.10 33.27 30.15];
//cf_fb_gain = [0.871402, 0.882762, 0.891443, 0.901117];
cf_fb_gain = 10^(-3*(cf_d_time/1000)/decay);
cf_d_n = round(cf_d_time*fs/1000)
cf_d_idx = zeros(cf_d_n);
cf_d_l1 = zeros(1,cf_d_n(1));
cf_d_l2 = zeros(1,cf_d_n(2));
cf_d_l3 = zeros(1,cf_d_n(3));
cf_d_l4 = zeros(1,cf_d_n(4));
cf_d_l = cat(2, cf_d_l1, cf_d_l2, cf_d_l3, cf_d_l4);

// APF Parameter
apf_d_time = [5.0, 1.7]
apf_gain = [0.7 0.7];
apf_d_n = round(apf_d_time*fs/1000)
apf_d_idx = zeros(apf_d_n);
apf_d_l1 = zeros(1,apf_d_n(1));
apf_d_l2 = zeros(1,apf_d_n(2));
apf_d_l = cat(2, apf_d_l1, apf_d_l2);


// Multi Tup Delay Process
mtd_out = zeros(in);
pd_out = zeros(in);
for k =1:N
    d_idx = mtd_d_idx + 1;
    mtd_tap = mtd_tap_idx + 1;
    pd_tap = mtd_pre_tap_idx +1;
    for i = 1:size(mtd_d_time)(2), mtd_out(k) = mtd_out(k) + mtd_gain(i)*mtd_d_l(mtd_tap(i)), end;
    pd_out(k) = mtd_d_l(pd_tap);
    mtd_d_l(d_idx) = in(k);
    mtd_d_idx = modulo(d_idx, mtd_d_n)
    mtd_tap_idx = modulo(mtd_tap, mtd_d_n)
    mtd_pre_tap_idx = modulo(pd_tap, mtd_d_n);
end

//comb Filter process(Parallel)
cf_in = pd_out
cf_out = zeros(4, N)
idx_front = 0;
for i = 1:size(cf_d_time)(2)
    for k = 1:N
        d_idx = cf_d_idx(i) + 1;
        in_sig = cf_in(k);
        fb_sig = cf_d_l(idx_front + d_idx);
        cf_out(i,k) = fb_sig; // 出力
        cf_d_l(idx_front + d_idx) = in_sig + fb_sig*cf_fb_gain(i);
        cf_d_idx(i) = modulo(d_idx, cf_d_n(i));
    end
    idx_front = idx_front + cf_d_n(i);
end
cf_out = sum(cf_out, 1);

//All Pass Filter Process(Series)
apf_in = cf_out;
idx_front = 0;
for i = 1:size(apf_d_time)(2)
    for k = 1:N
        d_idx = apf_d_idx(i) + 1;
        in_sig = apf_in(k);
        fb_sig = apf_d_l(idx_front + d_idx);
        d_in = in_sig + fb_sig*apf_gain(i);
        apf_in(k) = fb_sig - d_in*apf_gain(i);
        apf_d_l(idx_front + d_idx) = d_in;
        apf_d_idx(i) = modulo(d_idx, apf_d_n(i));
    end
    idx_front = idx_front + apf_d_n(i);
end

apf_out = apf_in;

// Reverb Process
rev = apf_out*mu3 + mtd_out*mu2
out = mu1*in + rev;

// Plot
subplot(311)
plot(t, cf_out);
xlabel("Time [s]","font_size", 3);
ylabel("Amplitude","font_size", 3);
title("Combo filter signal","font_size", 3);

subplot(312);
plot(t, apf_out);
xlabel("Time [s]","font_size", 3);
ylabel("Amplitude","font_size", 3);
title("All pass filter signal","font_size", 3);

subplot(313);
plot(t, out);
xlabel("Time [s]","font_size", 3);
ylabel("Amplitude","font_size", 3);
title("Reverb effect signal","font_size", 3);


