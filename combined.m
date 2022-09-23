% get file from user any type
% ask user for integral, derivative and proportional values
% ask user for reference and feedback value - otherwise use 1





clear
clc


% ask user for file
[file,path] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.*'},'File Selector','MultiSelect','on');   % enable multipule selections
% check what file type was selected
[Path, Name, Ext]= fileparts(file);
filenum = length(cellstr(Name));          % determine number of files
if filenum > 1
    switch filenum
        case filenum
            % Multiple text files selected
            for m = 1:numel(file)
                filemat = cell2mat(file(m));
                Namemat = cell2mat(Name(m));
                fid = fopen(filemat, 'r') ;      % open file to read
                for n = 1:5                   % Remove first 5 lines
                    fgetl(fid);
                end
                buffer = fread(fid, Inf) ;    % store data in buffer variable
                fclose(fid);
                newName = sprintf('%s-data.txt',Namemat);         % add data to previous name
                fid = fopen(newName, 'w')  ;                   % open new file to write
                fwrite(fid, buffer) ;                          % write stored data to new file
                fclose(fid);
                fopen(newName,'r');
                newCell = textscan(fid,'%s','delimiter','\n');      % insert text file data into cell array
                newCell = newCell{1};
                cellkeep = newCell;
                fclose(fid);
                k = contains(newCell,'0');                          % find zero values
                F = find(~k);                                       % get index of non-numeric values
                for n =1:length(F)
                    newCell(F(length(F)+1-n),:) = [];               % remove lines of non-numeric values - with operation done backwards to avoid line numbers changing
                end
                start = 1;                                          % take 1st data series of each file if there are multiple
                End = F(1)-1;
                newCell = newCell(start:End,1);
                Datacell = split(newCell);                          % convert cell to correct dimensions
                Data = cell2mat(cellfun(@str2num,Datacell,'UniformOutput',false));    % convert cell array to matrix avoiding consistency error
                [row, col] = size(Data);       % get size of Data
                maxYarr = zeros(1,col-1);      % Preallocate array
                for i = 1:col-1                % plot all columns against the first column(time)
                    plot(Data(:,1),Data(:,i+1))
                    maxYarr(i) = max(Data(:,i+1));   % get max value of each series
                    hold on
                end
                maxY = max(maxYarr);                            % determine maximum Y value
                axishandle = gca();                             % get axis handle
                ylim(axishandle,[0,maxY+maxY/10])               % set y-axis limit for readability
                title('Closed Loop Control')                    % Title
                
            end
            
            maxY = max(maxY);                               % determine maximum Y value
            axishandle = gca();                             % get axis handle
            ylim(axishandle,[0,maxY+maxY/10])               % set y-axis limit for readability
            title('Closed Loop Control')                    % Title
        otherwise
            error('All file types must be the same')        % error if user doesnt select only .txt files
    end
else
    switch (Ext)
        case '.txt'                       % if input file is single .txt
            fid = fopen(file, 'r') ;      % open file to read
            for n = 1:5                   % Remove first 5 lines
                fgetl(fid);
            end
            buffer = fread(fid, Inf) ;    % store data in buffer variable
            fclose(fid);
            newName = sprintf('%s-data.txt',Name);         % add data to previous name
            fid = fopen(newName, 'w')  ;                   % open new file to write
            fwrite(fid, buffer) ;                          % write stored data to new file
            fclose(fid);
            fopen(newName,'r');
            newCell = textscan(fid,'%s','delimiter','\n');      % insert text file data into cell array
            newCell = newCell{1};
            cellkeep = newCell;
            fclose(fid);
            k = contains(newCell,'0');                          % find zero values
            F = find(~k);                                       % get index of non-numeric values
            i1=find(diff(F)~=1);  % finds where sequences of consecutive numbers end
            [t,b]=size(i1);   % finds dimensions of I_1 i.e. how many sequences of consecutive numbers you have
            userinput = 1;
            if userinput > t+1
                error('File only contains %d data series',t+1)
            elseif userinput == 0             % if all data series are selected
                for n =1:length(F)
                    newCell(F(length(F)+1-n),:) = [];               % remove lines of non-numeric values - with operation done backwards to avoid line numbers changing
                end
            elseif userinput == 1             % if first data series is selected
                start = 1;
                End = F(1)-1;
                newCell = newCell(start:End,1);
            else                              % if any other data series is selected
                start = F(i1(userinput-1))+1;
                End = F(i1(userinput-1)+1)-1;
                newCell = newCell(start:End,1);
            end
            Datacell = split(newCell);                          % convert cell to correct dimensions
            Data = cell2mat(cellfun(@str2num,Datacell,'UniformOutput',false));    % convert cell array to matrix avoiding consistency error
            [~, col] = size(Data);       % get size of Data
            maxYarr = zeros(1,col-1);      % Preallocate array
            for i = 1:col-1                % plot all columns against the first column(time)
                plot(Data(:,1),Data(:,i+1))
                maxYarr(i) = max(Data(:,i+1));   % get max value of each series
                hold on
            end
            maxY = max(maxYarr);                            % determine maximum Y value
            axishandle = gca();                             % get axis handle
            ylim(axishandle,[0,maxY+maxY/10])               % set y-axis limit for readability
            title('Closed Loop Control')                    % Title
        case '.xlsx'                                        % if input file is excel file(.xlsx)
            excelfile = sprintf('%s.xlsx',Name);
            [~,sheet_names]=xlsfinfo(excelfile);            % reads sheet names
            numsheets = numel(sheet_names);                 % get number of sheets
            data = cell(1,numsheets);                       % preallocate data cell
            for p=1:numsheets
                data{p}=xlsread('Control lab data.xlsx',sheet_names{p});    % read excel data into 'data'
            end
            for d = 1:numsheets
                title('Closed Loop Control')
                dat = cell2mat(data(d));
                [r,c] = size(dat);            % get size of data on sheet
                for d2 = 1:c-1                                              % loop over all columns
                    dispname = sprintf('series %g-%g',d,d2);                     % naming of each series
                    plot(dat(:,1),dat(:,d2+1),'displayname',dispname)       % plot all columns against first column(time)
                    hold on
                end
                legend('-dynamiclegend')
            end
        otherwise
            error('Unexpected file extension: %s', Ext);
    end
end