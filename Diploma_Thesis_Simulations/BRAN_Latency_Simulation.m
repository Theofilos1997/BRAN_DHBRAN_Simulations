function [Mean_Delay] = BRAN_Latency_Simulation(M,la,lb,lc,N,s)
% Simulation of Blockchain Radio Access Network (B-RAN)
% Parameters (Inputs):
% M: Number of access requests completed before simulation termination
% la: Access request arrival rate
% lb: Block generation rate
% lc: Service completion rate
% N: Number of confirmations (blocks) required
% s: Maximum number of requests simultaneously serving
% Output:
% Mean delay of the requests

    Sim_Flag = true;    % Flag to terminate the simulation
    % Start the simulation (arrival of request 1 at time = 0)
    Event_List = [1;0;1];
    % Counter of requests
    Request_ID = 0;
    % Queue of requests
    Q = zeros(4,0);
    % Vector of delay values of requests
    Delay_Values = zeros(1,0);
    
    % Mean exponential time between two request arrivals
    ta = 1 / la;
    % Vector of exponential time values between request arrivals
    Dt = exprnd(ta,[1,M-1]);
    % Vector of request arrival times
    Arrivals = zeros(1,M);
    for m=2:M
        Arrivals(m) = Arrivals(m-1) + Dt(m-1);
    end
    
    % Mean exponential service completion time
    tc = 1 / lc;
    % Vector of times to complete each request after starting its service
    tservice = exprnd(tc,[1,M]);
    
    % Mean exponential time between two block generations
    tb = 1 / lb;
    
    % Main event - driven simulation loop
    while Sim_Flag

        Event = Event_List(1,1);
        Time = Event_List(2,1);

        if Event == 1
            [Event_List,Request_ID,Q] = Event1(Event_List,Request_ID,Q,Arrivals,M,tb,N);
        elseif Event == 2
            [Event_List,Q] = Event2(Event_List,Q,s,N,tservice);
        elseif Event == 3
            [Event_List,Q,Delay_Values] = Event3(Event_List,Q,Delay_Values,N,tservice);
        elseif Event == 4
            [Sim_Flag,Mean_Delay] = Event4(Delay_Values);
        end

        Event_List(:,1)=[];
        Event_List=(sortrows(Event_List',[2,3]))';
        
        % Terminate simulation if the Evnet_List is empty
        if isempty(Event_List)
            Event_List(1,end+1) = 4;
            Event_List(2,end) = Time;
            Event_List(3,end) = 1;
        end

    end

end

% Event1: Arrival of a request
function [Event_List,Request_ID,Q] = Event1(Event_List,Request_ID,Q,Arrival_Times,M,tb,N)

    % Arrival of a new access request
    Request_ID = Request_ID + 1;
    %sprintf('Arrival of request with ID %d',Request_ID)
    
    % Append the new request to the queue
    Q(1,end+1) = Request_ID;                % Request ID
    Q(2,end) = Arrival_Times(Request_ID);   % Arrival time
    Q(3,end) = 0;                           % Number of confirmations
    Q(4,end) = -1;                          % Start service time
    
    % Find the number of block generation events already at the Event_List
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
    
    % Generate the blocks required to confirm the request
    if n < N
        
        % Vector of exponential time values between block arrivals
        Ub = exprnd(tb,[1,N-n]);
        
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
    
    % Call Event1 to trigger the next request arrival (create not more than M requests)
    if Request_ID < M
        Event_List(1,end+1) = 1;
        Event_List(2,end) = Arrival_Times(Request_ID+1);
        Event_List(3,end) = 1;
    end

end

% Event2: Generation of a block
function [Event_List,Q] = Event2(Event_List,Q,s,N,tservice)

    % Generation (arrival) of a new block
    %sprintf('Block generation')
    
    % One more confirmation for each request in queue
    Q(3,:) = Q(3,:) + 1;
    
    % Find the current number of requests in service:
    Serving = 0;
    for i=1:size(Q,2)
        if Q(4,i) ~= -1
            Serving = Serving + 1;
        end
    end
    
    % Start service for confirmed request, if there are available network resources
    for i=1:size(Q,2)
        if Q(3,i) >= N && Q(4,i) == -1 && Serving < s
            % Start service
            Q(4,i) = Event_List(2,1);
            % Increase the counter of serving request
            Serving = Serving + 1;
            % Call Event3 to terminate the service of this request
            Event_List(1,end+1) = 3;
            Event_List(2,end) = Event_List(2,1) + tservice(Q(1,i));
            Event_List(3,end) = 1;
            % Add one more row to Event_List, to keep the ID of the request
            Event_List(4,end) = Q(1,i);
        end
    end

end


%Event3: Service completion of a request
function [Event_List,Q,Delay_Values] = Event3(Event_List,Q,Delay_Values,N,tservice)

    %sprintf('Service completion of the request with ID %d',Event_List(4,1))
    
    % Terminate the service of the request with the ID carried by Event_List
    for i=1:size(Q,2)
        if Q(1,i) == Event_List(4,1)
            % Calculate the delay of the completed request
            Delay_Values(end+1) = Q(4,i) - Q(2,i);
            % Delete the request from queue
            Q(:,i) = [];
            break
        end
    end
    
    % Start service of a completed request, if existing
    for i=1:size(Q,2)
        if Q(3,i) >= N && Q(4,i) == -1
            % Start service
            Q(4,i) = Event_List(2,1);
            % Call Event3 to terminate the service of this request
            Event_List(1,end+1) = 3;
            Event_List(2,end) = Event_List(2,1) + tservice(Q(1,i));
            Event_List(3,end) = 1;
            % Add one more row to Event_List, to keep the ID of the request
            Event_List(4,end) = Q(1,i);
            break
        end
    end

end

%Event4: Simulation termination and average delay extraction
function [Sim_Flag,Mean_Delay] = Event4(Delay_Values)

    % Termination of the simulation
    Sim_Flag = false;
    sprintf('Simulation End')
    
    % Mean delay calculation
    Mean_Delay = mean(Delay_Values);

end