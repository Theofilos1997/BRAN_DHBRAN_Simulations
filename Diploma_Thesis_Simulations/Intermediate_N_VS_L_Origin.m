K = 1000000;
lb1 = 30;
lb2 = 30;
lc = 1;
M = [1 2 3 4 5 6 7 8 9 10];
N = [1 2 3 4 5 6 7 8 9 10];
s = 5;
Results = zeros(0,3);

% Low intensity
parfor i=1:length(N)
    Results(i,1) = Intermediate_BRAN_Latency_Simulation(K,0.4,lb1,lb2,lc,M(i),N(i),s);
end

% Medium intensity
parfor i=1:length(N)
    Results(i,2) = Intermediate_BRAN_Latency_Simulation(K,1.6,lb1,lb2,lc,M(i),N(i),s);
end

% High intensity
parfor i=1:length(N)
    Results(i,3) = Intermediate_BRAN_Latency_Simulation(K,2.8,lb1,lb2,lc,M(i),N(i),s);
end

writematrix(Results,'Intermediate_N_VS_L.txt');
type Intermediate_N_VS_L.txt