%
% PLSC - Partial Least Square Correlation analysis between brain and
% cogntive variables
%
% This script reproduce PLSC results reported in the manuscript
% "Brain structure-function coupling provides signatures for task decoding and individual fingerprinting"
% Alessandra Griffa, Enrico Amico, Raphaël Liégeois, Dimitri Van De Ville, Maria Giulia Preti
% NeuroImage, Volume 250, 2022, 118970, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2022.118970.
% 

clear
close all
clc

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% SETTINGS

% Select on which data (datatype) you want to run PLSC
% 1 = Structural-Decoupling Index (SDI) -> 379 feature
% 2 = functional connactivity (FC) nodal strength -> 379 features
% 3 = coupled-FC -> 71'631 features
% 4 = decoupled-FC -> 71'631 features
% 5 = FC -> 71'631 features
datatype = 4;

% Select the task on which you want to run PLSC
% 1 = RESTING STATE
% 2 = EMOTION
% 3 = GAMBLING
% 4 = LANGUAGE
% 5 = MOTOR
% 6 = RELATIONAL
% 7 = SOCIAL
% 8 = WORKING MEMORY
tasktype = 1;

% NOTE: add myPLS folder to MATALB path
% addpath(genpath('path/to/myPLS'))

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% Project directory
findpath = which('PLSC_FullPipeline.m');
project_dir = erase(findpath, '/Code/PLSC_FullPipeline.m');
addpath(genpath(fullfile(project_dir, 'Code')));

% Number of subejcts
ns = 100;



%% Load input data
switch datatype
    case 1
        feature_string = 'SDI';
        filename = dir(fullfile(project_dir, 'Data', 'Final_SDI', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Brain data (n_features X n_observations)
        data = SDIs;
        clear SDIs
    
    case 2
        feature_string = 'FC nodal strength';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FCns', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Brain data (n_features X n_observations)
        data = FCns;
        clear FCns
        
    case 3
        feature_string = 'c-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_c-FC', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Brain data (n_features X n_observations)
        data = FClf';
        clear FClf
     
    case 4    
        feature_string = 'd-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_d-FC', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Brain data (n_features X n_observations)
        data = FChf';
        clear FChf
        
    case 5
        feature_string = 'FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FC', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Brain data (n_features X n_observations)
        data = FC';
        clear FC   
end

% Number of features         
na = size(data,1);         

% Load cognitive scores
load(fullfile(project_dir, 'Data', 'Final_Cognition', '10features_Cognition_ScoreSign.mat')); % Bpca, domains
Y = Bpca;
ystring = domains;
clear Bpca domains

% Display input data - COGNITION
figure, imagesc(zscore(Y)), xlabel('10 cognitive scores (z-scored)'), ylabel('subjects');
xticks(1:length(ystring)), xticklabels(ystring), xtickangle(45), colorbar, set(gcf,'color','w'), set(gca,'fontsize',18);
     


%% SELECT TASK
tasks = {'REST', 'EMOTION', 'GAMBLING', 'LANGUAGE', 'MOTOR', 'RELATIONAL', 'SOCIAL', 'WM'}';
this_task = tasks{tasktype};

ii = find(strcmp(tasks,this_task));
disp(['LR ' this_task ': ' num2str((ii-1)*ns*2+1) ':' num2str((ii-1)*ns*2+ns)]);
disp(['RL ' this_task ': ' num2str((ii-1)*ns*2+ns+1) ':' num2str(ii*ns*2)]);

% Extract data for current task
LR = data(:,(ii-1)*ns*2+1:(ii-1)*ns*2+ns);
RL = data(:,(ii-1)*ns*2+ns+1:ii*ns*2);

% Average LR-RL
clear X
X = squeeze(mean(cat(3,LR,RL),3))';
ii_nan = find(isnan(X(:,1)));
X = X(setdiff(1:ns,ii_nan),:);
ns = size(X,1);

clear LR RL

% Display input data - BRAIN
figure, imagesc(X), xlabel(['features (' feature_string ')']), ylabel('subjects'), title(['feature matrix (' feature_string ', ' tasks{tasktype} ')']);
colormap(jet), colorbar, set(gcf,'color','w'), set(gca,'fontsize',18);



%% Run PLSC for brain-cognition multivariate correlation

myPLS_inputs_brain_cognition;
[input,pls_opts,save_opts] = myPLS_initialize(input,pls_opts,save_opts);
res = myPLS_analysis(input,pls_opts);

if min(res.LC_pvals) < 0.05
    close all
    
    ii_sig = find(res.LC_pvals == min(res.LC_pvals));
    [r,p] = corr(res.Ly(:,ii_sig),res.Lx(:,ii_sig));
    figure, plot(res.Ly(:,ii_sig),res.Lx(:,ii_sig),'o','markerfacecolor','k','markeredgecolor','w','markersize',10); 
    xlabel('cognitive latent scores'), ylabel('brain latent scores'), title(['r-squared = ' num2str(r*r,3)]), grid on;
    set(gcf,'color','w'), set(gca,'fontsize',18);
    
    plot_surface_glasser(project_dir,res.V(1:360,ii_sig),othercolor('YlOrRd5'),prctile(res.V(1:360,ii_sig),5),prctile(res.V(1:360,1),95));
    colormap(othercolor('YlOrRd5')), colorbar;
    
    figure, bar(res.U(:,ii_sig),'edgecolor','k','facecolor','w','linewidth',1.5), title('Cognitive saliences'), ylabel('PLSC weights');
    grid on, xticks(1:length(ystring)), xticklabels(ystring), xtickangle(45), set(gcf,'color','w'), set(gca,'fontsize',18);
end


