K = 1000000;
lb1 = [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
lb2 = [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
lc = 1;
M = 2;
N = 2;
s = 3;
Results = zeros(0,3);

% Low intensity
parfor i=1:length(lb1)
    Results(i,1) = Intermediate_BRAN_Latency_Simulation(K,0.4,lb1(i),lb2(i),lc,M,N,s);
end

% Medium intensity
parfor i=1:length(lb1)
    Results(i,2) = Intermediate_BRAN_Latency_Simulation(K,1.6,lb1(i),lb2(i),lc,M,N,s);
end

% High intensity
parfor i=1:length(lb1)
    Results(i,3) = Intermediate_BRAN_Latency_Simulation(K,2.8,lb1(i),lb2(i),lc,M,N,s);
end

writematrix(Results,'Intermediate_N_VS_L.txt');
type Intermediate_N_VS_L.txt