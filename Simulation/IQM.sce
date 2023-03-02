xdel
clear
clc

f = [800 3200 4800 12000 19000]
A = [0.5 1 1.5 0.2 0.8]
fs = 44000

//note_n = 128
// fc = 440 * 2^(((0:note_n-1) - 69)/12)

fc_max = 22000
fc = 0:fc_max

dt = 1/fs
point = 2048;
p = 0:point-1
t = 0:dt:dt*(point-1)
spc = zeros(fc)

sub_sig = sin(2*%pi*f'*t)
sig = zeros(1,point);
for i =1:5, sig = sig + A(i)*sub_sig(i,:), end


for i = 1:size(fc)(2)
    sigcs = sin(2*%pi*fc(i)*t)
    sigcc = cos(2*%pi*fc(i)*t)
    I = sum(sig.*sigcs)
    Q = sum(sig.*sigcc)
    spc(i) = sqrt(I^2+Q^2)
end

plot2d(fc, spc./max(spc))
xlabel("$Frequency[Hz]$", "fontsize", 3);
ylabel("$Magnitude$", "fontsize", 3);
