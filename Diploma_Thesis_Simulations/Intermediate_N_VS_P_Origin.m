K = 1000000;
lb1 = 30;
lb2 = 30;
lc = 1;
M = [1 2 3 4 5 6 7 8 9 10];
N = [1 2 3 4 5 6 7 8 9 10];
s = 5;
r_low = 0.1;
r_medium = 0.4;
r_high = 0.7;
P_low = zeros(0,3);
P_medium = zeros(0,3);
P_high = zeros(0,3);

% Low intensity
for i=1:length(N)
    P = Intermediate_BRAN_WaitingProb_Simulation(K,r_low*s*lc,lb1,lb2,lc,M(i),N(i),s);
    P_low(i,1) = P(1);
    P_low(i,2) = P(2);
    P_low(i,3) = P(3);
end

% Medium intensity
for i=1:length(N)
    P = Intermediate_BRAN_WaitingProb_Simulation(K,r_medium*s*lc,lb1,lb2,lc,M(i),N(i),s);
    P_medium(i,1) = P(1);
    P_medium(i,2) = P(2);
    P_medium(i,3) = P(3);
end

% High intensity
for i=1:length(N)
    P = Intermediate_BRAN_WaitingProb_Simulation(K,r_high*s*lc,lb1,lb2,lc,M(i),N(i),s);
    P_high(i,1) = P(1);
    P_high(i,2) = P(2);
    P_high(i,3) = P(3);
end

P_low
P_medium
P_high