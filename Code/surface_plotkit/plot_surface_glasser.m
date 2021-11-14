%
% EXAMPLE USAGE colorsurf_2hemi_5perspectives 
%
function plot_surface_glasser(mypath,this_vector,this_cm,min_val,max_val)

%% Plotting
plotkit_dir = fullfile(mypath,'surface_plotkit');
path_surf_rh = fullfile(plotkit_dir, 'data', 'fsaverage', 'surf', 'rh.pial');
path_surf_lh = fullfile(plotkit_dir, 'data', 'fsaverage', 'surf', 'lh.pial');
path_annot_rh = fullfile(plotkit_dir, 'data', 'fsaverage', 'label', 'rh.HCP-MMP1.annot');
path_annot_lh = fullfile(plotkit_dir, 'data', 'fsaverage', 'label', 'lh.HCP-MMP1.annot');

% Load Glasser parcellation info
load(fullfile(plotkit_dir,'data','labels_glasser_subcortical.mat'));
ncortical = 360;


% Map SDI values to colors of colormap
CM = squeeze(mapsc2rgb(this_vector, this_cm));

CM = squeeze(mapsc2rgb(this_vector, this_cm, min_val, max_val));
[k1,k2] = colorsurf_2hemi_5perspectives(path_surf_rh, path_annot_rh, ...
    path_surf_lh, path_annot_lh, CM, labels_glasser(1:ncortical),...
    5, 'gouraud');


end