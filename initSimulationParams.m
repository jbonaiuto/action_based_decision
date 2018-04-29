function simParams=initSimulationParams(protocolParams)

simParams.nTrials = 1;
simParams.tMax = 500;

simParams.xh = 0;           % Hand initial x-poisition
simParams.yh = 0;           % Hand initial y-poisition
simParams.xe = 0;           % Eye initial x-position
simParams.ye = 0;           % Eye initial y-position

%simParams.xh_vis=0;         % Visual hand x-position
%simParams.yh_vis=0;         % Visual hand y-position

% State vector for reaching movement
simParams.Xhand = zeros(10,1); 
simParams.Xhand(1)=simParams.xh; 
simParams.Xhand(2)=simParams.yh;
simParams.Xhand(9)=protocolParams.target_positions(1,1); 
simParams.Xhand(10)=protocolParams.target_positions(1,2);
% State vector for saccadic movement
simParams.Xeye = zeros(6,1); 
simParams.Xeye(1)=simParams.xe; 
simParams.Xeye(2)=0; 
simParams.Xeye(3)=simParams.ye;  
simParams.Xeye(4)=0; 
simParams.Xeye(5)=protocolParams.target_positions(1,1); 
simParams.Xeye(6)=protocolParams.target_positions(1,2);

simParams.running=0;

simParams.eye_dist_targets=[];
simParams.hand_dist_targets=[];
for i=1:size(protocolParams.target_positions,1)
    rx=protocolParams.target_positions(i,1);
    ry=protocolParams.target_positions(i,2);
    simParams.eye_dist_targets=[simParams.eye_dist_targets; sqrt((simParams.xe-rx)^2  + (simParams.ye-ry)^2)];
    simParams.hand_dist_targets=[simParams.hand_dist_targets; sqrt((simParams.xh-rx)^2  + (simParams.yh-ry)^2)];
end
simParams.minEyeDist=min(simParams.eye_dist_targets);
simParams.minHandDist=min(simParams.hand_dist_targets);

simParams.Threshold_contact   = 5;

simParams.flag_contact     = 0;
simParams.chosen_effector  = 0; % 0=none, 1=eye, 2=hand
simParams.chosen_target    = 0; % 0=none, 1=left, 2=right

simParams.thr_perf_saccade    = 0.9;
simParams.thr_perf_reach      = 0.9;
simParams.output_u_sac_thr    = 0.1;
simParams.output_u_rch_thr    = 0.05;

simParams.revaluate_threshold = 50;
simParams.stim_input_reward_threshold = 0.3;







