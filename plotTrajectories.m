function plotTrajectories(base_dir, protocol, n_trials)
rx1 = -12;        % Initial x-position of the target 1
ry1 =  40;        % Initial y-position of the target 1

rx2 = 12;         % Initial x-position of the target 2
ry2 = 40;         % Initial y-position of the target 2

figure; hold on
circle([rx1 ry1],7,1000,3)
circle([rx2 ry2],7,1000,3)
plot(0,0,'sk')
%plot(Trajectory(1,:),Trajectory(2,:),'k','LineWidth',3)
training_iter=[1, 3, 5];
iter_c=['b','r','g'];
for trial=1:n_trials
    if protocol==5
        for i=1:length(training_iter)
            output=open([base_dir num2str(training_iter(i)) '/trial.' num2str(trial) '.trajectory.mat']);
            color=iter_c(i);
            plot(output.Trajectory(1,:)*-1,output.Trajectory(2,:),color,'LineWidth',3)
        end
    else
        output=open([base_dir 'trial.' num2str(trial) '.trajectory.mat']);
        color='b';    
        if (protocol==1 || protocol==2) && output.Trajectory(1,length(output.Trajectory(1,:)))<0
            color='r';
        end
        plot(output.Trajectory(1,:),output.Trajectory(2,:),color,'LineWidth',3)
    end
end
axis equal
