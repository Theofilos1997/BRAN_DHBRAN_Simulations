M = 1000000;
lb = [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
lc = 1;
s = 3;
N = 2;
Results = zeros(0,3);

% Low intensity
parfor i=1:length(lb)
    Results(i,1) = BRAN_Latency_Simulation(M,0.4,lb(i),lc,N,s);
end

% Medium intensity
parfor i=1:length(lb)
    Results(i,2) = BRAN_Latency_Simulation(M,1.6,lb(i),lc,N,s);
end

% High intensity
parfor i=1:length(lb)
    Results(i,3) = BRAN_Latency_Simulation(M,2.8,lb(i),lc,N,s);
end

writematrix(Results,'N_VS_L.txt');
type N_VS_L.txt