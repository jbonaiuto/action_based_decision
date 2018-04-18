function TwoFields(debug)

close all
clc

fig = figure('Position',[50,50,1200,700],'Name','Neural Field',...
  'Color','w','NumberTitle','off','MenuBar','none');

% create axes for field plots
topAxes    = axes('Position',[0.1 0.65 0.85 0.3]);
bottomAxes = axes('Position',[0.1 0.3 0.85 0.3]);
trajAxes   = axes('Position',[0.1 0.3 0.85 0.3]);

topAxes    = axes('Position',[0.1 0.75 0.85 0.2]);
bottomAxes = axes('Position',[0.1 0.45  0.85 0.2]);

% create sliders for model parameters
controlFieldHeight = 0.04;
controlFieldWidth = 0.3;
sliderWidth = 0.15;
gapWidth = 0.01;
textWidth = controlFieldWidth - sliderWidth - gapWidth;

controlParamNames = {'dnf1.params.h_u','dnf1.params.c_exc','dnf1.params.c_inh','dnf1.params.g_inh','dnf1.params.q_u',...
    'dnf1.params.beta_u','dnf2.params.h_u','dnf2.params.c_exc','dnf2.params.c_inh','dnf2.params.g_inh','dnf2.params.q_u',...
    'dnf2.params.beta_u'};
controlPosX = [0, 0, 1, 1, 0, 0, 1, 1, 2, 2, 2, 2] * controlFieldWidth;
controlPosY = [5, 4, 5, 4, 3, 2, 3, 2, 5, 4, 3, 2] * controlFieldHeight;
controlMin = [-10, 0, 0, 0, 0, 0, -10, 0, 0, 0, 0, 0];
controlMax = [0, 100, 100, 5, 1.5, 5.0, 0, 100, 100, 5, 1.5, 5.0];
textFormat = {'%0.1f', '%0.1f', '%0.1f', '%0.2f', '%0.2f', '%0.2f','%0.1f', '%0.1f', '%0.1f', '%0.2f', '%0.2f', '%0.2f'};

if debug==0
    close all
end

control_point = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define parameters
N = 100;                % duration in number of time steps

%%Targets position and hand fixation
xh = 0;           % Hand initial x-poisition
yh = 0;           % Hand initial y-poisition

rx1 = -12;        % Initial x-position of the target 1
ry1 =  40;        % Initial y-position of the target 1

rx2 = 12;         % Initial x-position of the target 2
ry2 = 40;         % Initial y-position of the target 2

%%%%%%%%%%%%%%%%%%%%
% model parameters %
%%%%%%%%%%%%%%%%%%%%

dnf1Params=initDNFParams();
dnf1Params.c_inh = 30;
dnf1Params.c_exc = 15;
dnf2Params=initDNFParams();
dnf2Params.c_inh = 30;
dnf2Params.c_exc = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulation time course %
%%%%%%%%%%%%%%%%%%%%%%%%%%

nTrials = 1;
tMax = 500;

% set times at which field activities are stored (different variants)
% tStoreFields = [100, 200]; % select specific time steps
tStoreFields = 1:tMax; % store field activities at every time step
% tStoreFields = 1:5:tMax; % store field activities every 5th time step

% set times of stimulus presentation
% for multiple separate stimuli in one trial, repeat this for each one
% (e. g. tStimulusStart1 = ..., tStimulusStart2 = ...)
tStimulusStart = 50;
tStimulusEnd   = 450;
tStimulusDuration = tStimulusEnd-tStimulusStart;

%%%%%%%%%%%%%%%%%%
% initialization %
%%%%%%%%%%%%%%%%%%

dnf1=initDNF(dnf1Params, nTrials, tStoreFields);
dnf2=initDNF(dnf2Params, nTrials, tStoreFields);

%%%%%%%%%%%%%%%%%%%%
% Init Controllers %
%%%%%%%%%%%%%%%%%%%%
nControlParams = length(controlParamNames);
sliders = zeros(nControlParams, 1);
textFields = zeros(nControlParams, 1);
if debug>0
  for i = 1 : nControlParams
    eval(['tmp = ' controlParamNames{i} ';']);
    sliders(i) = uicontrol(fig, 'Style', 'Slider', 'Units', 'Norm', 'Position', ...
      [controlPosX(i)+textWidth+gapWidth, controlPosY(i), sliderWidth, controlFieldHeight], ...
      'Value', tmp, 'Min', controlMin(i), 'Max', controlMax(i), 'Callback', @sliderCallback);
    textFields(i) = uicontrol(fig,'Style','Text','Units','Norm','HorizontalAlignment', 'left', ...
      'String',[controlParamNames{i} '=' num2str(tmp, textFormat{i})], 'BackgroundColor', 'w',...
      'Position',[controlPosX(i)+gapWidth, controlPosY(i) textWidth controlFieldHeight]);
  end
end


%%%%%%%%%%%%%%
% simulation %
%%%%%%%%%%%%%%

Distance_from_origin_T1 = sqrt((xh-rx1)^2  + (yh-ry1)^2); %current distance from target 1
Distance_from_origin_T2 = sqrt((xh-rx2)^2  + (yh-ry2)^2); %current distance from target 1
distance_from_origin    = min(Distance_from_origin_T1,Distance_from_origin_T2);

stimulus1=zeros(1,dnf1.params.fieldSize);
stimulus2=zeros(1,dnf2.params.fieldSize);

% plot graphs
actPlot_u1=0;
outPlot_u1=0;
actPlot_u2=0;
outPlot_u2=0;
inPlot1=0;
inPlot2=0;
kernelPlot1=0;
kernelPlot2=0;
if debug>0
  axes(topAxes);
  cla;
  hold on;
  plot([0,dnf1.params.fieldSize-1],[0,0],'Linestyle',':','Linewidth',1);
  actPlot_u1 = plot(0:dnf1.params.fieldSize-1,dnf1.field_u,'color','b','Linewidth',3);
  outPlot_u1 = plot(0:dnf1.params.fieldSize-1,10*dnf1.output_u,'color','r','Linewidth',1);
  inPlot1 = plot(0:dnf1.params.fieldSize-1,stimulus1+dnf1.params.h_u,'color','g','Linewidth',1);
  actPlot_u2 = plot(0:dnf2.params.fieldSize-1,dnf2.field_u,'color','b','Linewidth',3,'LineStyle','--');
  outPlot_u2 = plot(0:dnf2.params.fieldSize-1,10*dnf2.output_u,'color','r','Linewidth',1,'LineStyle','--');
  inPlot2 = plot(0:dnf2.params.fieldSize-1,stimulus2+dnf2.params.h_u,'color','g','Linewidth',1,'LineStyle','--');
  set(gca,'ylim',[-15,15],'xlim',[0,dnf1.params.fieldSize-1],'Ytick',[-10,0,10]);
  ylabel('u field','Fontsize',12);
  hold off;

  axes(bottomAxes);
  cla;
  hold on;
  plot([-dnf1.params.halfField,dnf1.params.halfField],[0,0],'Linestyle',':','Linewidth',1);
  kernelPlot1 = plot(-dnf1.params.halfField:dnf1.params.halfField, ...
      [zeros(1, dnf1.params.halfField-dnf1.kSize_uu) dnf1.kernel_uu zeros(1, dnf1.params.halfField-dnf1.kSize_uu)] - dnf1.params.g_inh, 'Color', 'r', 'Linewidth', 3);
  kernelPlot2 = plot(-dnf2.params.halfField:dnf2.params.halfField, ...
      [zeros(1, dnf2.params.halfField-dnf2.kSize_uu) dnf2.kernel_uu zeros(1, dnf2.params.halfField-dnf2.kSize_uu)] - dnf2.params.g_inh, 'Color', 'r', 'Linewidth', 3, 'LineStyle', '--');
  set(gca,'ylim',[-10,10],'xlim',[-dnf1.params.halfField,dnf1.params.halfField],'Ytick',[-10,-5,0,5,10]);
  ylabel('interaction kernel','Fontsize',12);
  hold off;
end

% loop over trials
for i = 1 : nTrials
    
    disp(['trial ' num2str(i)]);
    
    dnf1=resetDNF(dnf1);
    dnf2=resetDNF(dnf2);
    
    % State vector
    xh = 0;           % Hand initial x-poisition
    yh = 0;           % Hand initial y-poisition
    stimulus1  =0.0;
    stimulus2  =0.0;

    stim1Coeff=10.0;
    stim2Coeff=10.0;
    
    % loop over time steps
    for t = 1 : tMax
        
        %Target related biases
        [theta1,rho1] = cart2pol(rx1-xh,ry1-yh);
        theta1=(theta1/pi)*180.0;
        [theta2,rho2] = cart2pol(rx2-xh,ry2-yh);
        theta2=(theta2/pi)*180.0;
        stim1 = stim1Coeff*gauss(1:dnf1.params.fieldSize, round(theta1), 5)+stim1Coeff*gauss(1:dnf1.params.fieldSize, round(theta2), 5); % a localized input
        stim2 = stim2Coeff*gauss(1:dnf2.params.fieldSize, round(theta1), 5)+stim2Coeff*gauss(1:dnf2.params.fieldSize, round(theta2), 5);; % a localized input

        if t<tStimulusStart 
            stimulus1   = stim1-1.75*sum(dnf2.output_u(:));
            stimulus2   = stim2-1.75*sum(dnf1.output_u(:));
        elseif t>tStimulusEnd
            stimulus1 = zeros(1,dnf1.params.fieldSize);
            stimulus2 = zeros(1,dnf2.params.fieldSize);
        end
        
        
        disp(['t=' num2str(t)]);
        dnf1=runDNF(dnf1, stimulus1, tStoreFields, t);
        dnf2=runDNF(dnf2, stimulus2, tStoreFields, t);
    
        if debug>0
            set(inPlot1, 'Ydata', stimulus1+dnf1.params.h_u);
            set(actPlot_u1,'Ydata',dnf1.field_u);
            set(outPlot_u1,'Ydata',10*dnf1.output_u);
            set(inPlot2, 'Ydata', stimulus2+dnf2.params.h_u);
            set(actPlot_u2,'Ydata',dnf2.field_u);
            set(outPlot_u2,'Ydata',10*dnf2.output_u);
            drawnow;
        end
        
    end
    
end


nStoredFields = nTrials * length(tStoreFields);

figure;
subplot(3, 1, 1);
imagesc(dnf1.history_s');
xlabel('time');
ylabel('stimulus');
colorbar();
subplot(3, 1, 2);
imagesc(dnf1.history_u');
xlabel('time');
ylabel('activity u');
colorbar();
subplot(3, 1, 3);
imagesc(dnf1.history_output');
xlabel('time');
ylabel('output u');
colorbar();

figure;
subplot(3, 1, 1);
imagesc(dnf2.history_s');
xlabel('time');
ylabel('stimulus');
colorbar();
subplot(3, 1, 2);
imagesc(dnf2.history_u');
xlabel('time');
ylabel('activity u');
colorbar();
subplot(3, 1, 3);
imagesc(dnf2.history_output');
xlabel('time');
ylabel('output u');
colorbar();

% view evolution of field activities in each trial as mesh plot
nFieldsPerTrial = length(tStoreFields);
if 0
    disp('Press any key to iterate through trials');
    figure;
    for i = 1 : nStoredFields
        plot(0:dnf1.params.fieldSize-1, zeros(1, dnf1.params.fieldSize), ':k', ...
            1:dnf1.params.fieldSize, dnf1.history_s(i, :), '--g', ...
            1:dnf1.params.fieldSize, dnf1.history_mu(i, :) + dnf1.params.h_u, '-c', ...
            1:dnf1.params.fieldSize, dnf1.history_u(i, :), '-b');
        set(gca, 'XLim', [0 dnf1.params.fieldSize-1], 'YLim', [-15 15]);
        ylabel('activity u');
        drawnow;
        pause(0.01);
    end
    for i = 1 : nTrials
        subplot(2, 1, 1);
        mesh(1:dnf1.params.fieldSize, tStoreFields, ...
            dnf1.history_u((i-1)*nFieldsPerTrial+1 : i*nFieldsPerTrial, :));
        zlabel('activity u');
        subplot(2, 1, 2);
        mesh(1:dnf1.params.fieldSize, tStoreFields, ...
            dnf1.history_mu((i-1)*nFieldsPerTrial+1 : i*nFieldsPerTrial, :));
        zlabel('memory trace u');
        pause
    end
end

% view mesh plot of all stored field activities together
if 0
    figure;
    subplot(2, 1, 1);
    mesh(1:dnf1.params.fieldSize, 1:nStoredFields, dnf1.history_u(:, :));
    zlabel('activity u');
    subplot(2, 1, 2);
    mesh(1:dnf1.params.fieldSize, 1:nStoredFields, dnf1.history_mu(:, :));
    zlabel('memory trace u');
end

% update paramter values after slider changed
function sliderCallback(hObject, eventdata) %#ok<INUSD>
  sliderChanged = find(hObject == sliders);

  paramName = controlParamNames{sliderChanged};
  tmp = get(sliders(sliderChanged), 'Value');
  set(textFields(sliderChanged), 'String', [paramName '=' num2str(tmp, textFormat{sliderChanged})]);
  eval([paramName '= tmp;']);
  dnf1.kernel_uu = dnf1.params.c_exc * gaussNorm(-dnf1.params.halfField:dnf1.params.halfField, 0, dnf1.params.sigma_exc) ...
    - dnf1.params.c_inh * gaussNorm(-dnf1.params.halfField:dnf1.params.halfField, 0, dnf1.params.sigma_inh) - dnf1.params.g_inh;
  dnf1.kernel_mu = dnf1.params.c_mu * gaussNorm(-dnf1.params.halfField:dnf1.params.halfField, 0, dnf1.params.sigma_mu);
  set(kernelPlot1,'YData',[zeros(1, dnf1.params.halfField-dnf1.kSize_uu) dnf1.kernel_uu zeros(1, dnf1.params.halfField-dnf1.kSize_uu)] - dnf1.params.g_inh);
  dnf2.kernel_uu = dnf2.params.c_exc * gaussNorm(-dnf2.params.halfField:dnf2.params.halfField, 0, dnf2.params.sigma_exc) ...
    - dnf2.params.c_inh * gaussNorm(-dnf2.params.halfField:dnf2.params.halfField, 0, dnf2.params.sigma_inh) - dnf2.params.g_inh;
  dnf2.kernel_mu = dnf2.params.c_mu * gaussNorm(-dnf2.params.halfField:dnf2.params.halfField, 0, dnf2.params.sigma_mu);
  set(kernelPlot2,'YData',[zeros(1, dnf2.params.halfField-dnf2.kSize_uu) dnf2.kernel_uu zeros(1, dnf2.params.halfField-dnf2.kSize_uu)] - dnf2.params.g_inh);
end
end



