function protocolParams=initCueFirstProtocolParams()

protocolParams=initProtocolParams();
protocolParams.protocol=1;

% set times of stimulus presentation
%protocolParams.tStimulusStart = 50;
%protocolParams.tTarget        = 100;
%protocolParams.tStimulusEnd   = 350;

protocolParams.tStimulusStart = 1;
protocolParams.tTarget        = 40;
protocolParams.tStimulusEnd   = 350;