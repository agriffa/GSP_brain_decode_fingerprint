%
% SVM for task decoding 
%
% This script reproduce task decoding results reported in the manuscript
% "Brain structure-function coupling provides signatures for task decoding and individual fingerprinting"
% Alessandra Griffa, Enrico Amico, Raphaël Liégeois, Dimitri Van De Ville, Maria Giulia Preti
% bioRxiv 2021.04.19.440314; doi: https://doi.org/10.1101/2021.04.19.440314
% 

clear
close all
clc

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% SETTINGS

% Select on which data (datatype) you want to run the TASK DECODING
% 1 = Structural-Decoupling Index (SDI) -> 379 feature
% 2 = functional connactivity (FC) nodal strength -> 379 features
% 3 = coupled-FC -> 71'631 features
% 4 = decoupled-FC -> 71'631 features
% 5 = FC -> 71'631 features
datatype = 1;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% Project directory
findpath = which('task_decoding_FullPipeline.m');
project_dir = erase(findpath, '/Code/task_decoding_FullPipeline.m');

% Number of subejcts
ns = 100;



%% Load input data
switch datatype
    case 1
        feature_string = 'SDI';
        filename = dir(fullfile(project_dir, 'Data', 'Final_SDI', '*TASK_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = SDIs';
        clear SDIs
    
    case 2
        feature_string = 'FC nodal strength';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FCns', '*TASK_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FCns';
        clear FCns
        
    case 3
        feature_string = 'c-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_c-FC', '*TASK_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FClf;
        clear FClf
     
    case 4    
        feature_string = 'd-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_d-FC', '*TASK_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FChf;
        clear FChf
        
    case 5
        feature_string = 'FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FC', '*TASK_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FC;
        clear FC   
end

% Number of data points (acquisition)         
na = size(X,1);         

% Display input data
figure, imagesc(X), xlabel(['features (' feature_string ')']), ylabel('acquisitions'), title(['feature matrix (' feature_string ')']);
colormap(jet), colorbar, set(gcf,'color','w'), set(gca,'fontsize',18); 
     


%% Prepare labels for the na data points (fMRI acquisitions)
% task_label = task label
% edir_label = encoding direction label
% subj_label = subject label
tasks = {'REST', 'EMOTION', 'GAMBLING', 'LANGUAGE', 'MOTOR', 'RELATIONAL', 'SOCIAL', 'WM'}';
edir = {'LR','RL'};
% Loop over tasks
task_label = cell(na,1);
edir_label = cell(na,1);
subj_label = nan(na,1);
clc
for i = 1:length(tasks)

    disp(' ');
    disp(['LR ' tasks{i} ': ' num2str((i-1)*ns*2+1) ':' num2str((i-1)*ns*2+ns)]);
    disp(['RL ' tasks{i} ': ' num2str((i-1)*ns*2+ns+1) ':' num2str(i*ns*2)]);
    
    task_label( (i-1)*ns*2+1 : i*ns*2 ) = {tasks{i}};
    
    edir_label( (i-1)*ns*2+1 : (i-1)*ns*2+ns ) = {edir{1}}; 
    edir_label( (i-1)*ns*2+ns+1 : i*ns*2 ) = {edir{2}};
    
    subj_label( (i-1)*ns*2+1 : (i-1)*ns*2+ns ) = 1:ns;
    subj_label( (i-1)*ns*2+ns+1 : i*ns*2 ) = 1:ns;
end



%% SVM for task decoding

Y = task_label;         % response data (class labels)

% 100-FOLD (LEAVE-ONE-SUBJECT-OUT) CV
t = templateSVM('kernelfunction','linear','standardize',true); 
error_test = 0;     % initialize the number of misclassifications
% Loop over subject
for s = 1:ns
    
    disp([classifier ' TASK DECODING: CV loop ' num2str(s) ' of ' num2str(ns)])
    
    % Split data into training and test set
    ii_train = find(subj_label ~= s);
    ii_test = find(subj_label == s);
    Xtrain = X(ii_train,:);
    Ytrain = Y(ii_train);
    Xtest = X(ii_test,:);
    Ytest = Y(ii_test);
    
    % Train calssifier
    % Train nc(nc – 1)/2 binary support vector machine (SVM) models using 
    % the ONE-VERSUS-ONE coding design, where K is the number of unique class labels
    Mdltrain = fitcecoc(Xtrain,Ytrain,'Learners',t,'ClassNames',tasks,'verbose',0); 

    % Predict class of unseen data using SVM model
    label = predict(Mdltrain,Xtest);
    
    % Update number of misclassification
    error_test = error_test + sum(~strcmp(label,Ytest));
    
end
    
error_test = error_test / na;
accuracy_test = 1 - error_test;

clc
disp(['TASK DECODING ACCURACY for ' feature_string ', leave-one-subject-out (100-fold) CV']);
disp(['accuracy = ' num2str(accuracy_test,3)]);


