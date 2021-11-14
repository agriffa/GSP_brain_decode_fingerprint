%
% SVM for individual fingerprinting 
%
% This script reproduce individual fingerprinting results reported in the manuscript
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

% Select on which data (datatype) you want to run the INDIVIDUAL FINGERPRINTING
% 1 = Structural-Decoupling Index (SDI) -> 379 feature
% 2 = functional connactivity (FC) nodal strength -> 379 features
% 3 = coupled-FC -> 71'631 features
% 4 = decoupled-FC -> 71'631 features
% 5 = FC -> 71'631 features
datatype = 1;

% Select cross-validation configuration
% 1 = 800-fold (leave-one-subject’s-task-out) CV -> return one accuracy value
% 2 = leave-one-subject-and-task-out CV -> return 56 accuracy values, one for each task-pair combinations (resting-state and 7 tasks) 
cvtype = 1;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% Project directory
findpath = which('individual_fingerprinting_FullPipeline.m');
project_dir = erase(findpath, '/Code/individual_fingerprinting_FullPipeline.m');

% Number of subejcts
ns = 100;



%% Load input data
switch datatype
    case 1
        feature_string = 'SDI';
        filename = dir(fullfile(project_dir, 'Data', 'Final_SDI', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = SDIs';
        clear SDIs
    
    case 2
        feature_string = 'FC nodal strength';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FCns', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FCns';
        clear FCns
        
    case 3
        feature_string = 'c-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_c-FC', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FClf;
        clear FClf
     
    case 4    
        feature_string = 'd-FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_d-FC', '*SUBJECT_CLASSIFICATION*'));
        load(fullfile(filename.folder, filename.name));
        % Prepare feature matrix X (n_observations X n_features)
        X = FChf;
        clear FChf
        
    case 5
        feature_string = 'FC';
        filename = dir(fullfile(project_dir, 'Data', 'Final_FC', '*SUBJECT_CLASSIFICATION*'));
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



%% SVM for subject fingerprinting
switch cvtype
    case 1
        
        % LEAVE-ONE-SUBJECT'S-TASK-OUT CV (800-FOLD CV)
        % Test fold: LR and RL acq. of subject s, task bs
        % Training fold: all other data (1600 - 2 = 1598 data points)

        % SETTINGS
        t = templateSVM('kernelfunction','linear','standardize',true); 
        error1_test = 0;     % initialize the number of misclassifications
        norm_factor = 0;
        count = 0;
        options = statset('UseParallel',true);

        % Loop over subject
        for s = 1:ns
            for b = 1:length(tasks)    

                count = count + 1;
                disp(['BRAIN FINGERPRINTING, CV 1: CV loop ' num2str(count) ' of ' num2str(ns*length(tasks))]);

                % Split data into training and test folds
                ii_test = intersect(find(subj_label == s), find(strcmp(task_label, tasks{b}))); 
                ii_train = setdiff(1:na,ii_test);
                Xtest = X(ii_test,:);
                Ytest = Y(ii_test);
                Xtrain = X(ii_train,:);
                Ytrain = Y(ii_train);

                % SVM ONE-VERSUS-ALL coding design
                Mdltrain = fitcecoc(Xtrain,Ytrain,'Learners',t,'ClassNames',1:ns,'verbose',0,'Coding','onevsall','Options',options);	

                % Predict class of unseen data using SVM model
                label = predict(Mdltrain,Xtest);

                % Number of misclassification
                norm_factor = norm_factor + length(Ytest);
                error1_test = error1_test + sum(label ~= Ytest);

            end
        end

        error1_test = error1_test / norm_factor;
        accuracy1_test = 1 - error1_test;
        
        clc
        disp(['INDIVIDUAL FINGERPRINTING ACCURACY for ' feature_string ', leave-one-subject-task-out (800-FOLD) CV']);
        disp(['accuracy = ' num2str(accuracy_test,3)]);
        
        
    case 2
        
        % LEAVE-ONE-SUBEJCT-AND-TASK-OUT CV
        % Repeat CV (8 * 7 = 56) times !
        % Test fold: LR and RL acq. of subject s, task bs
        % Train fold: only data from ONE DIFFERENT TASK
        
        % SETTINGS
        t = templateSVM('kernelfunction','linear','standardize',true); 
        nt = length(tasks);     % number of tasks
        error2_test = zeros(nt);
        count = 0;

        % PREDICT FROM TASK A (TRAINING FOLD) TO TASK B (TEST FOLD)
        for a = 1:nt            

            % Prepare training fold
            count = count + 1;
            ii_train = find(strcmp(task_label, tasks{a}));
            Xtrain = X(ii_train,:);
            Ytrain = Y(ii_train);

            % Train classifier
            % SVM ONE-VERSUS-ALL coding design
            Mdltrain = fitcecoc(Xtrain,Ytrain,'Learners',t,'ClassNames',1:ns,'verbose',0,'Coding','onevsall');

            % Loop over possible test datasets
            for b = 1:nt

                if a == b
                    continue
                end

                % For this tasks' configuration, classify test subjects
                disp(['TRAINING TASK ' num2str(a) ', TEST TASK ' num2str(b) ]);

                % Prepare test fold
                ii_test = find(strcmp(task_label, tasks{b})); 
                Xtest = X(ii_test,:);
                Ytest = Y(ii_test);

                % Predict class of unseen data using SVM model
                label = predict(Mdltrain,Xtest);

                % Number of misclassification
                error2_test(a,b) = sum(label ~= Ytest) / length(Ytest);

            end

        end
        
        mask = double(~eye(nt));
        mask(mask == 0) = nan;
        accuracy2_test = ( 1 - error2_test ) .* mask;
        
        clc
        disp(['INDIVIDUAL FINGERPRINTING ACCURACY for ' feature_string ', leave-one-subject-and-task-out CV']);
        disp('ALL TASK-PAIR COMBINATIONS EXPLORED');
        disp(' ');
        disp('tasks = ');
        disp(tasks);
        disp('accuracies = ');
        disp(num2str(accuracy2_test,3));
        
        
end



