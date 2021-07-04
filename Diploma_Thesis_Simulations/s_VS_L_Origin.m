M = 1000000;
lb = 28;
lc = 1;
N = 2;
s = 1:2:25;
r_low = 0.1;
r_medium = 0.4;
r_high = 0.7;
Results = zeros(0,3);

% Low intensity
parfor i=1:length(s)
    Results(i,1) = BRAN_Latency_Simulation(M,r_low*s(i)*lc,lb,lc,N,s(i));
end

% Medium intensity
parfor i=1:length(s)
    Results(i,2) = BRAN_Latency_Simulation(M,r_medium*s(i)*lc,lb,lc,N,s(i));
end

% High intensity
parfor i=1:length(s)
    Results(i,3) = BRAN_Latency_Simulation(M,r_high*s(i)*lc,lb,lc,N,s(i));
end

writematrix(Results,'s_VS_L.txt');
type s_VS_L.txt