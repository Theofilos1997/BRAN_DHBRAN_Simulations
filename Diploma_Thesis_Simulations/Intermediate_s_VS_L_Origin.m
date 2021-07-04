K = 1000000;
lb1 = 30;
lb2 = 30;
lc = 1;
M = 2;
N = 2;
s = 1:2:25;
r_low = 0.1;
r_medium = 0.4;
r_high = 0.7;
Results = zeros(0,3);

% Low intensity
parfor i=1:length(s)
    Results(i,1) = Intermediate_BRAN_Latency_Simulation(K,r_low*s(i)*lc,lb1,lb2,lc,M,N,s(i));
end

% Medium intensity
parfor i=1:length(s)
    Results(i,2) = Intermediate_BRAN_Latency_Simulation(K,r_medium*s(i)*lc,lb1,lb2,lc,M,N,s(i));
end

% High intensity
parfor i=1:length(s)
    Results(i,3) = Intermediate_BRAN_Latency_Simulation(K,r_high*s(i)*lc,lb1,lb2,lc,M,N,s(i));
end

writematrix(Results,'Intermediate_s_VS_L.txt');
type Intermediate_s_VS_L.txt