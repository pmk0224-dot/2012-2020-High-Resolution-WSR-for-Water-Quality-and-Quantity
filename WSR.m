MRIO.Import(isnan(MRIO.Import)) = 0
MRIO.Z(isnan(MRIO.Z)) = 0
MRIO.VA(isnan(MRIO.VA)) = 0
input = sum(MRIO.Z) + MRIO.Import(1, 1:13146) + sum(MRIO.VA(:, 1:13146), 1);
%% input
input = input(1, 1:13146)
input(input ==0) = eps
B = MRIO.Z ./ input
LWSR = readmatrix('C:\Users\DELL\Desktop\LWSR\2012LWSR.xlsx');
%% WSR
E = eye(size(B));
M = E - B;
try
    invM = inv(M);
catch ME
    fprintf('矩阵不可逆: %s\n', ME.message);
    return;
end
% 
D = diag(LWSR);
WSR = D * invM;
%%
VWSR = WSR-diag(LWSR)