A = [0 -1; -1 0]
B1 = eye(2,2)
B2 = [0; 1]
C1 = [sqrt(2)*eye(2,2); 0 0]
D11 = zeros(3,2)
D12 = [0; 0; sqrt(3)]

Q = C1'*C1
R = D12'*D12
S = C1'*D12

[P1,P2] = riccati(A, B2*inv(R)*B2', Q, 'd')
P = clean(P1*inv(P2))
F = -inv(R + B2'*P*B2)*[D12' B2'*P]*[C1 D11; A B1]
K = F(:, 1:2)
K2 = F(:, 3:4)

z_norm = zeros(1, 20)
x = [3; 0]
w = [0; 0]
for i = 1:100
    z = (C1 + D12*K)*x + (D11 + D12*K2)*w
    x = (A + B2*K)*x + (B1 + B2*K2)*w
    z_norm(i) = z'*z   
end

disp(clean(z_norm))
