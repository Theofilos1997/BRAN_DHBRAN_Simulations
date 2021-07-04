function [Waiting_Probabilities] = Intermediate_BRAN_WaitingProb_Simulation(K,la,lb1,lb2,lc,M,N,s)
% Simulation of Blockchain Radio Access Network (B-RAN)
% Parameters (Inputs):
% K: Number of access requests completed before simulation termination
% la: Access request arrival rate
% lb1: Block generation rate (primary mining network)
% lb2: Block generation rate (secondary mining network)
% lc: Service completion rate
% M: Number of blocks required to confrrm a request (primary mining network)
% N: Number of blocks required to confrrm a request (secondary mining network)
% s: Maximum number of requests simultaneously serving
% Output:
% Vector of waiting probabilities
% 1) Wait for available link
% 2) Wait for available link more than 1 time unit
% 3) Wait for available link more than 2 time units

    Sim_Flag = true;    % Flag to terminate the simulation
    % Start the simulation (arrival of request 1 at time = 0)
    Event_List = [1;0;1];
    % Counter of requests
    Request_ID = 0;
    % Queue of requests
    Q = zeros(5,0);
    % Vector of start service times (for each request)
    Start_Serv_Times = zeros(1,M);
    % Vector of confirmation times (for each request)
    Confirmation_Times = zeros(1,M);
    % Vector of probabilities to wait more than 0, 1 and 2 time units
    Waiting_Probabilities = zeros(1,3);
    
    % Mean exponential time between two request arrivals
    ta = 1 / la;
    % Vector of exponential time values between request arrivals
    Dt = exprnd(ta,[1,K-1]);
    % Vector of request arrival times
    Arrival_Times = zeros(1,K);
    for k=2:K
        Arrival_Times(k) = Arrival_Times(k-1) + Dt(k-1);
    end
    
    % Mean exponential service completion time
    tc = 1 / lc;
    % Vector of times to complete each request after starting its service
    Service_Times = exprnd(tc,[1,K]);
    
    % Mean exponential time between two block generations (primary mining network)
    tb1 = 1 / lb1;
    % Mean exponential time between two block generations (secondary mining network)
    tb2 = 1 / lb2;
    
    % Main event - driven simulation loop
    while Sim_Flag

        Event = Event_List(1,1);
        Time = Event_List(2,1);

        if Event == 1
            [Event_List,Request_ID,Q] = Event1(Event_List,Request_ID,Q,Arrival_Times,tb2,N,K);
        elseif Event == 2
            [Event_List,Q] = Event2(Event_List,Q,N);
        elseif Event == 3
            [Event_List,Q] = Event3(Event_List,Q,tb1,M);
        elseif Event == 4
            [Event_List,Q,Confirmation_Times] = Event4(Event_List,Q,M,s,Service_Times,Confirmation_Times);
        elseif Event == 5
            [Event_List,Q,Start_Serv_Times] = Event5(Event_List,Q,M,Service_Times,Start_Serv_Times);
        elseif Event == 6
            [Sim_Flag,Waiting_Probabilities] = Event6(Confirmation_Times,Start_Serv_Times,Waiting_Probabilities,K);
        end

        Event_List(:,1)=[];
        Event_List=(sortrows(Event_List',[2,3]))';
        
        % Terminate simulation if the Evnet_List is empty
        if isempty(Event_List)
            Event_List(1,end+1) = 6;
            Event_List(2,end) = Time;
            Event_List(3,end) = 1;
        end

    end

end

% Event1: Arrival of a request from a device to an intermediate user' s device
function [Event_List,Request_ID,Q] = Event1(Event_List,Request_ID,Q,Arrival_Times,tb2,N,K)

    % Arrival of a new access request
    Request_ID = Request_ID + 1;
    %sprintf('Secondary network: Arrival of request with ID %d at time %d',Request_ID,Event_List(2,1))
    
    % Append the new request to the queue
    Q(1,end+1) = Request_ID;                % Request ID
    Q(2,end) = Arrival_Times(Request_ID);   % Arrival time
    Q(3,end) = 0;                           % Number of confirmations (primary)
    Q(4,end) = 0;                           % Number of confirmations (secondary)
    Q(5,end) = -1;                          % Start service time
    
    % Find the number of secondary network block generation events already at the Event_List
    n = 0;
    Prev_Times = zeros(1,0);
    for i=1:size(Event_List,2)
        if Event_List(1,i) == 2
            % Increase the block generation event counter
            n = n + 1;
            % Keep the times of block generation events
            Prev_Times(end+1) = Event_List(2,i);
        end
    end
    
    % Generate the blocks required to confirm the request (at the secondary network)
    if n < N
        
        % Vector of exponential time values between block arrivals
        Ub = exprnd(tb2,[1,N-n]);
        % Block generation times
        tblocks = zeros(1,N-n);
        % Make sure that the new blocks are generating after the already existing blocks
        if isempty(Prev_Times)
            tblocks(1) = Arrival_Times(Request_ID) + Ub(1);
        else
            tblocks(1) = max(Prev_Times) + Ub(1);
        end
        % Exponential times for the generation of the other blocks
        for i=2:(N-n)
            tblocks(i) = Ub(i) + tblocks(i-1);
        end
        
        % Call Event2 to generate the required blocks
        for i=1:size(tblocks,2)
            Event_List(1,end+1) = 2;
            Event_List(2,end) = tblocks(i);
            Event_List(3,end) = 1;
        end
        
    end
    
    % Call Event1 to trigger the next request arrival (create not more than K requests)
    if Request_ID < K
        Event_List(1,end+1) = 1;
        Event_List(2,end) = Arrival_Times(Request_ID+1);
        Event_List(3,end) = 1;
    end

end

% Event2: Generation of a secondary network block
function [Event_List,Q] = Event2(Event_List,Q,N)

    % Generation (arrival) of a new secondary network block
    %sprintf('Secondary network block generation at time %d',Event_List(2,1))
    
    % One more confirmation for each request at the secondary network
    for i=1:size(Q,2)
        if Q(4,i) ~= -1
            Q(4,i) = Q(4,i) + 1;
        end
    end
    
    % Confirmed requests are pushed to the prinary network
    for i=1:size(Q,2)
        if Q(4,i) >= N
            Event_List(1,end+1) = 3;
            Event_List(2,end) = Event_List(2,1);
            Event_List(3,end) = 1;
            % Add one more row to Event_List, to keep the ID of the request
            Event_List(4,end) = Q(1,i);
        end
    end

end

% Event3: Arrival of a request from an intermediate user to an access point (to serve another user)
function [Event_List,Q] = Event3(Event_List,Q,tb1,M)

    % Arrival of a request to the primary network
    %sprintf('Primary network: Arrival of request with ID %d at time %d',Event_List(4,1),Event_List(2,1))
    
    % The request comes out of the secondary network
    for i=1:size(Q,2)
        if Q(1,i) == Event_List(4,1)
            Q(4,i) = -1;
            break
        end
    end
    
    % Find the number of primary network block generation events already at the Event_List
    m = 0;
    Prev_Times = zeros(1,0);
    for i=1:size(Event_List,2)
        if Event_List(1,i) == 4
            % Increase the block generation event counter
            m = m + 1;
            % Keep the times of block generation events
            Prev_Times(end+1) = Event_List(2,i);
        end
    end
    
    % Generate the blocks required to confirm the request (at the primary network)
    if m < M
        
        % Vector of exponential time values between block arrivals
        Ub = exprnd(tb1,[1,M-m]);
        % Block generation times
        tblocks = zeros(1,M-m);
        % Make sure that the new blocks are generating after the already existing blocks
        if isempty(Prev_Times)
            tblocks(1) = Event_List(2,1) + Ub(1);
        else
            tblocks(1) = max(Prev_Times) + Ub(1);
        end
        % Exponential times for the generation of the other blocks
        for i=2:(M-m)
            tblocks(i) = Ub(i) + tblocks(i-1);
        end
        
        % Call Event4 to generate the required blocks
        for i=1:size(tblocks,2)
            Event_List(1,end+1) = 4;
            Event_List(2,end) = tblocks(i);
            Event_List(3,end) = 1;
        end
        
    end

end

% Event4: Generation of a primary network block
function [Event_List,Q,Confirmation_Times] = Event4(Event_List,Q,M,s,Service_Times,Confirmation_Times)

    % Generation (arrival) of a new primry network block
    %sprintf('Primary network block generation at time %d',Event_List(2,1))
    
    % One more confirmation for each request at the primary network
    for i=1:size(Q,2)
        if Q(4,i) == -1
            Q(3,i) = Q(3,i) + 1;
        end
    end
    
    % Register confirmation times for the requests confirmed now
    for i=1:size(Q,2)
        if Q(3,i) == M
            Confirmation_Times(Q(1,i)) = Event_List(2,1);
        end
    end
    
    % Find the current number of requests in service:
    Serving = 0;
    for i=1:size(Q,2)
        if Q(5,i) ~= -1
            Serving = Serving + 1;
        end
    end
    
    % Start service for confirmed request, if there are available network resources
    for i=1:size(Q,2)
        if Q(3,i) >= M && Q(5,i) == -1 && Serving < s
            % Start service
            Q(5,i) = Event_List(2,1);
            % Increase the counter of serving request
            Serving = Serving + 1;
            % Call Event3 to terminate the service of this request
            Event_List(1,end+1) = 5;
            Event_List(2,end) = Event_List(2,1) + Service_Times(Q(1,i));
            Event_List(3,end) = 1;
            % Add one more row to Event_List, to keep the ID of the request
            Event_List(4,end) = Q(1,i);
        end
    end

end

% Event5: Service completion of a request
function [Event_List,Q,Start_Serv_Times] = Event5(Event_List,Q,M,Service_Times,Start_Serv_Times)

    %sprintf('Service completion of the request with ID %d at time %d',Event_List(4,1),Event_List(2,1))
    
    % Terminate the service of the request with the ID carried by Event_List
    for i=1:size(Q,2)
        if Q(1,i) == Event_List(4,1)
            % Keep the start service time of the completed request
            Start_Serv_Times(Event_List(4,1)) = Q(5,i);
            % Delete the request from queue
            Q(:,i) = [];
            break
        end
    end
    
    % Start service of a completed request, if existing
    for i=1:size(Q,2)
        if Q(3,i) >= M && Q(5,i) == -1
            % Start service
            Q(5,i) = Event_List(2,1);
            % Call Event5 to terminate the service of this request
            Event_List(1,end+1) = 5;
            Event_List(2,end) = Event_List(2,1) + Service_Times(Q(1,i));
            Event_List(3,end) = 1;
            % Add one more row to Event_List, to keep the ID of the request
            Event_List(4,end) = Q(1,i);
            break
        end
    end

end

% Event6: Simulation termination and average delay extraction
function [Sim_Flag,Waiting_Probabilities] = Event6(Confirmation_Times,Start_Serv_Times,Waiting_Probabilities,K)

    % Termination of the simulation
    Sim_Flag = false;
    sprintf('Simulation End')
    
    % Waiting time of each request
    Waiting_Times = Start_Serv_Times - Confirmation_Times;
    % Counter of requests waiting more than 0, 1 and 2 time units
    Request_Counter = zeros(1,3);
    
    % Number of reqests waiting for resourses
    for i=1:size(Waiting_Times,2)
        if Waiting_Times(i) > 0
            Request_Counter(1) = Request_Counter(1) + 1;
        end
    end
    
    % Number of reqests waiting for resourses more than 1 time unit
    for i=1:size(Waiting_Times,2)
        if Waiting_Times(i) > 1
            Request_Counter(2) = Request_Counter(2) + 1;
        end
    end
    
    % Number of reqests waiting for resourses more than 2 time units
    for i=1:size(Waiting_Times,2)
        if Waiting_Times(i) > 2
            Request_Counter(3) = Request_Counter(3) + 1;
        end
    end
    
    % Waiting probabilities calculation
    Waiting_Probabilities = Request_Counter / K;

end