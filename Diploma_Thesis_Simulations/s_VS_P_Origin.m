M = 1000000;
lb = 30;
lc = 1;
N = 2;
s = 1:2:25;
r_low = 0.1;
r_medium = 0.4;
r_high = 0.7;
P_low = zeros(0,3);
P_medium = zeros(0,3);
P_high = zeros(0,3);

% Low intensity
for i=1:length(s)
    P = BRAN_WaitingProb_Simulation(M,r_low*s(i)*lc,lb,lc,N,s(i));
    P_low(i,1) = P(1);
    P_low(i,2) = P(2);
    P_low(i,3) = P(3);
end

% Medium intensity
for i=1:length(s)
    P = BRAN_WaitingProb_Simulation(M,r_medium*s(i)*lc,lb,lc,N,s(i));
    P_medium(i,1) = P(1);
    P_medium(i,2) = P(2);
    P_medium(i,3) = P(3);
end

% High intensity
for i=1:length(s)
    P = BRAN_WaitingProb_Simulation(M,r_high*s(i)*lc,lb,lc,N,s(i));
    P_high(i,1) = P(1);
    P_high(i,2) = P(2);
    P_high(i,3) = P(3);
end

P_low
P_medium
P_high