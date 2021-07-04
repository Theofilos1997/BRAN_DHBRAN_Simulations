M = 1000000;
lb = 30;
lc = 1;
s = 5;
N = [1 2 3 4 5 6 7 8 9 10];
Results = zeros(0,3);

% Low intensity
parfor i=1:length(N)
    Results(i,1) = BRAN_Latency_Simulation(M,0.4,lb,lc,N(i),s);
end

% Medium intensity
parfor i=1:length(N)
    Results(i,2) = BRAN_Latency_Simulation(M,1.6,lb,lc,N(i),s);
end

% High intensity
parfor i=1:length(N)
    Results(i,3) = BRAN_Latency_Simulation(M,2.8,lb,lc,N(i),s);
end

writematrix(Results,'N_VS_L.txt');
type N_VS_L.txt