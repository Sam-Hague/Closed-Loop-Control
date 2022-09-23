clear
clc
close all
tic
% reads sheet names and separates the data
[~,sheet_name]=xlsfinfo('Control lab data.xlsx');
data = cell(1,10);
for i=1:numel(sheet_name)       % insert sheet data into cell array
  data{i}=xlsread('Control lab data.xlsx',sheet_name{i});
end
Closedl = find(contains(sheet_name,'CL'));     % find closed loop sheets
hold on
overshoot = [0,0,0];        % preallocate arrays
peaktime = [0,0,0];
SSEVh = [0,0,0];            % Steady state error of Vq
SSEVq = [0,0,0];            % Steady state error of Vq
TTS = [0,0,0];              % time to settle
t = linspace(0,200,2000);   % time 
error = 2;                  % required error percentage
errband = [7*(1+error/100), 7*(1-error/100)];   
for i = 1:length(Closedl)
    dat = cell2mat(data(Closedl(i)));  % convert cell to matrix 
    Vh = sprintf('Vh %g',i);           % Labelling 
    Vq = sprintf('Vq %g',i);
    Vr = sprintf('Vr %g',i);
    if i == 4                          % Error calculation only needed for 2nd graph
        figure
        hold on
         plot([0,200],[6,6],'black','displayname','Vr')      % plot set voltage Vr
         Emin = plot([0,200],[min(errband),min(errband)],'black','displayname','errmin');    % plot min errorband
         Emax = plot([0,200],[max(errband),max(errband)],'black','displayname','errmax');    % plot max errorband
        legend('-dynamiclegend','Location', 'southeast')
        hold on
    end
    plot(dat(:,1),dat(:,2),'displayname',sprintf('Vq%g',i))      % plot Vq - second column
    plot(dat(:,1),dat(:,3),'displayname',sprintf('Vh%g',i))      % plot Vh - third column
    legend('-dynamiclegend')
    if i>=4                   % calculations performed on second graph - data 4,5,6
        axis([0,200,0,12])    % axes limits
        xlabel('Time(s)')     % labelling
        ylabel('Voltage(v)')
        title('Closed loop 4,5,6')
        [Maxdat,I] = max(dat(:,2));
        overshoot(i-3) = Maxdat- max(dat(:,4));
        peaktime(i-3) = dat(I,1);
        [xi1,yi1] = polyxpoly([0,200],[min(errband),min(errband)],dat(:,1),dat(:,2));  % find intersection of Emin and Vq
        [xi2,yi2] = polyxpoly([0,200],[max(errband),max(errband)],dat(:,1),dat(:,2));  % find intersection of Emax and Vq
        if isempty(xi1) && isempty(xi2)    % if Vq doesnt intersect either error band
            TTS(i-3) = 0;                  % time to settle is zero
        elseif isempty(xi1)
            TTS(i-3) = max(xi2);           
        elseif isempty(xi2)
            TTS(i-3) = max(xi1);
        else
            intmin = max(xi1,[],'all');
            intmax = max(xi2,[],'all');
            TTS(i-3) = max(intmin,intmax);          % TTS becomes the latest time that intersects
        end
        else
        axis([0,100,0,12])            % axes limits 
        xlabel('Time(s)')             % Labelling
        ylabel('Voltage(v)')
        
        title('Closed loop 1,2,3')
        SSEVh(i) = abs(mean(dat(600:1000,3))-max(dat(:,4)));
        SSEVq(i) = mean(dat(600:1000,2)-max(dat(:,4)));    % find average Vq value between 60 and 100s 
    end
end
toc
