function [gExc,gInh] = getConductances(cType)
%Function to load voltage clamp data and convert to excitatory and
%inhibitory conductances for modelling purposes.

%% Load vclamp velocity tuning data
%load exc and inh data
dTableFull = searchDataTables(1);
dTableExp = dTableFull(dTableFull.Stim == 'adj bars spds' & ...
    dTableFull.Drugs == 'none' & ...
    (dTableFull.RecordingType == 'v clamp inh' | dTableFull.RecordingType == 'v clamp exc'),:);

%only use trials that don't mention 'low contrast' in notes
isFullContrast = cellfun('isempty',regexpi(dTableExp.Notes,'low contrast'));
dTableExp = dTableExp(isFullContrast,:); %Only use full contrast v clamp sessions

%only use specified cell type
dTable = dTableExp(dTableExp.CellType == cType,:);
assert(~isempty(dTable),'No experiments match the specified cell type %s',cType);

nRows = size(dTable,1); %includes exc and inh
nCells = nRows/2; %just cell numbers

%% Initialize parameters

%Set up timing
dt = 100*1e-6; %sampling interval, in microseconds
tEnd = 8; %end of recording in seconds
tPts = round(tEnd / dt); %number of indices
tHoldEnd = 1;%sec, start of analysis window
tHold = 1:round(tHoldEnd / dt); %indices for subtracting holding current

%Filtering parameters
% dt = si*1e-6; %should be 0.1 ms;
N = round((20e-3) / dt); %avg 20 ms filter coefficient
avg20msFilter = ones(1,N)/N;

%Vclamp parameters
Eexc = 0e-3;
Einh = -72e-3;

%Initialize data holders
gExc = NaN(tPts,10,nCells); %On Conductances
gInh = NaN(tPts,10,nCells);

%% Load and pre-process On data
%Go through each row of dTable, processing exc and inh traces accordingly.
%Verifies preferred direction in stim file is correct via inhibition.

excCount = 1; %cell indx for excitation
inhCount = 1; %cell indx for inhibition
flipPDs = false; %flag for whether stims need to be flipped - determined by inh
inhExcHandoff = false; %flag to ensure proper switching between inh and exc, 
% so that preferred directions can be verified

for i = 1:nRows
    %Load data and stim files
    quickLoad(dTable.AcquisitionNumber(i),dTable.Date(i),1);
    quickStim(dTable.AcquisitionNumber(i),dTable.Date(i));
    stimSpds = stimInfo(:,2);
    
    %Lowpass filter currents
    d = filter(avg20msFilter,1,d);
    d = bsxfun(@minus,d,mean(d(tHold,:))); %subtract holding current from each trial
    %d = d - mean(d(tHold,1));%subtract holding current as mean current during holding period of 1st trial
    
    %Process exc or inh
    if dTable.RecordingType(i) == "v clamp exc"
        %Ensure preferred direction is verified via inh before exc
        if ~inhExcHandoff
            error('Previous recordings were not inh, PDs cannot be verified.')
        end
        
        %check if PDs need to be flipped
        if flipPDs
            stimSpds = -stimSpds;
        end
        
        % Process excitatory currents (expect negative values)
        dCond = ((d * 1e-12) ./ (Einh - Eexc)); %convert from pA to A, divide by driving force
        dCond(dCond < 0) = 0; %rectify conductances
        
        %Sort mean conductance traces
        gExc(:,:,excCount) = nanmean(quickSort(dCond,stimSpds),2);
        
        %Iterate counters / change flags
        excCount = excCount + 1;
        inhExcHandoff = false; %ensures going inh->exc->inh->exc so PDs can be verified
    else %inh loop
        %ensure exc is always following inh to verify preferred directions
        if inhExcHandoff
            error('Previous recordings was inh, PDs of exc cannot be verified.')
        end
        
        %Process inh currents (expect values to be positive)
        qTotal = sum(d)*dt; %take final value of cumulative sum as total charge transfer
        dCond = ((d * 1e-12) ./ (Eexc - Einh)); %convert from pA to A, divide by driving force
        dCond(dCond < 0) = 0; %rectify conductances
        
        %Check that there's more charge in null directions than positive
        if sum(qTotal(stimSpds > 0)) > sum(qTotal(stimSpds < 0))
            stimSpds = -stimSpds; %flip dirs if not
            flipPDs = true; %flag to flip PDs for corresponding exc recording
            fprintf('Flipping preferred direction for cell %s (%i)\n',dTable.CellID(i),floor((i-1)/2) + 1);
        else
            flipPDs = false;
        end
        
        %Sort mean conductance traces
        gInh(:,:,inhCount) = nanmean(quickSort(dCond,stimSpds),2);
        
        % Iterate counters / change flags
        inhCount = inhCount + 1;
        inhExcHandoff = true; %ensures going inh->exc->inh->exc so PDs can be verified
    end
    %     plotDirTraces(d,stimSpds,1,10000); plot sorted traces
end

% excModelCond = nanmean(gExc,3);
% inhModelCond = nanmean(gInh,3);

end