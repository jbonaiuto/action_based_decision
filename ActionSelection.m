
function [EffectorStateTotal ControlX ControlY] = ActionSelection(MotorOut,...
    ActivePop, dnf, W, lqgParams, Xstate, effector)

dnf_out=dnf.output_u*W;
Weights    = dnf_out(ActivePop)/sum(dnf_out(ActivePop));
ControlX = 0;
ControlY = 0;
for c_idx = 1:length(ActivePop)
    ControlX  = ControlX + Weights(c_idx)*MotorOut(ActivePop(c_idx)).x;
    ControlY  = ControlY + Weights(c_idx)*MotorOut(ActivePop(c_idx)).y;
end
EffectorStateTotal    = RunSimTraj(lqgParams,[ControlX ControlY]',Xstate,effector);

    
    


