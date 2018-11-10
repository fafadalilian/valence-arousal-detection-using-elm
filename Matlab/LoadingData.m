%% Clear all/ close figs
close all 
clear
clc

%% Setting Parameters
PARTICIPANTS_NUM = 32;
VIDEOS_NUM       = 40;
%% Load Data
addpath(genpath('Matlab/TEAP-master'));

matt_data_path = 'C:\Users\mjad9\Desktop\DEAP\MATLAB_data_preprocessed\';
amir_data_path = '~/Desktop/DEAP/MATLAB_data_preprocessed/';

data_path = amir_data_path;

if ~exist([data_path '/s30_eeglab.mat'],'file')
    loading_DEAP(data_path);
end 

feedbacks = readtable('~/Desktop/DEAP/participant_ratings.csv');

%% Extracting Features
for participant = 1:PARTICIPANTS_NUM
    eeglab_file = sprintf('%ss%0.2d_eeglab.mat', data_path, participant);
    disp(eeglab_file)
    bulk = Bulk_load(eeglab_file);
    
    means_array = [];
    std_array   = [];
    kurtosis_array = [];
    skewness_array = [];
    entropy_array =[];
    energy_array =[];
    
    for epoch = 1:VIDEOS_NUM
        %extracting EMG features
        [features(participant,epoch).EMG_feats, features(participant,epoch).EMG_feats_names] = EMG_feat_extr(bulk(epoch));
        %extracting EEG features
        [features(participant,epoch).EEG_feats, features(participant,epoch).EEG_feats_names] = EEG_feat_extr(bulk(epoch));
        %extracting GSR features
        [features(participant,epoch).GSR_feats, features(participant,epoch).GSR_feats_names] = GSR_feat_extr(bulk(epoch));
        %extracting BVP features
        %[features(participant,epoch).BVP_feats, features(participant,epoch).BVP_feats_names] = BVP_feat_extr(bulk(epoch));
        %extracting respiration features
        [features(participant,epoch).RES_feats, features(participant,epoch).RES_feats_names] = RES_feat_extr(bulk(epoch));
        
        feedback = feedbacks(feedbacks.Participant_id==participant & feedbacks.Experiment_id==epoch,:);
        
        features(participant,epoch).feedback.felt_arousal     = feedback.Arousal;
        features(participant,epoch).feedback.felt_valence     = feedback.Valence;
        features(participant,epoch).feedback.felt_dominance   = feedback.Dominance;
        features(participant,epoch).feedback.felt_liking      = feedback.Liking;
        features(participant,epoch).feedback.felt_familiarity = feedback.Familiarity;
        
        video_signal   = Bulk_get_signal(bulk(epoch), 'EEG');
        video_raw_data = cell2mat(struct2cell(video_signal.raw));
        [mean, std, kurtosis, skewness] = Signal_feat_stat_moments(video_raw_data, 'Skip');
        energy = Signal_feat_energy(video_raw_data, 'Skip');

        means_array = [means_array, mean];
        std_array = [std_array, std];
        kurtosis_array = [kurtosis_array, kurtosis];
        skewness_array = [skewness_array, skewness];
        entropy_array = [entropy_array, entropy(video_raw_data)'];
        energy_array = [energy_array, energy'];
        fprintf('extracted all the features for subject %d epoch %d\n',participant, epoch);
    end
    
    means_matrix{participant} = means_array;
    std_matrix{participant} = std_array;
    kurtosis_matrix{participant} = kurtosis_array;
    skewness_matrix{participant} = skewness_array;
    entropy_matrix{participant} =  entropy_array;
    energy_matrix{participant} = energy_array;
end

save([data_path 'deap_features.mat'],'features');


%% Exploring the data
delta      = [];
theta      = [];
slow_alpha = [];
alpha      = [];
beta       = [];
gamma      = [];
valence_labels   = [];
arousal_labels   = [];
dominance_labels = [];
liking_labels    = [];
participant = 1;
video       = 1;

for participant = 1:PARTICIPANTS_NUM
    for video = 1:VIDEOS_NUM
        delta      = [delta, features(participant,video).EEG_feats(1, :)];
        theta      = [theta, features(participant,video).EEG_feats(2, :)];
        slow_alpha = [slow_alpha, features(participant,video).EEG_feats(3, :)];
        alpha      = [alpha, features(participant,video).EEG_feats(4, :)];
        beta       = [beta, features(participant,video).EEG_feats(5, :)];
        gamma      = [gamma, features(participant,video).EEG_feats(6, :)];
        
        valence   = features(participant,video).feedback.felt_valence;
        arousal   = features(participant,video).feedback.felt_arousal;
        dominance = features(participant,video).feedback.felt_dominance;
        liking    = features(participant,video).feedback.felt_liking;

        valence_labels   = [valence_labels, repmat(valence > 5, 1, 32)];
        arousal_labels   = [arousal_labels, repmat(arousal > 5, 1, 32)];
        dominance_labels = [dominance_labels, repmat(dominance > 5, 1, 32)];
        liking_labels    = [liking_labels, repmat(liking > 5, 1, 32)];

%         delta_array(participant,video) = mean(features(participant,video).EEG_feats(1,:)); 
%         theta_array(participant,video) = mean(features(participant,video).EEG_feats(2,:)); 
%         slowalpha_array(participant,video) = mean(features(participant,video).EEG_feats(3,:)); 
%         alpha_array(participant,video) = mean(features(participant,video).EEG_feats(4,:)); 
%         beta_array(participant,video) = mean(features(participant,video).EEG_feats(5,:)); 
%         gamma_array(participant,video) = mean(features(participant,video).EEG_feats(6,:)); 
        
    end
end

means_features = cell2mat(means_matrix');
std_features = cell2mat(std_matrix');
kurtosis_features = cell2mat(kurtosis_matrix');
skewness_features = cell2mat(skewness_matrix');
entropy_features = cell2mat(entropy_matrix');
energy_features = cell2mat(energy_matrix');
features_array = [delta' theta' slow_alpha' alpha' beta' gamma' means_features(:) std_features(:) kurtosis_features(:) skewness_features(:) entropy_features(:) energy_features(:)];
fetures_array = zscore(features_array);
labels         = [valence_labels' arousal_labels' dominance_labels' liking_labels'];

for i = 1:size(valence_labels,2)
    if(valence_labels(i) == 1 && arousal_labels(i) == 1)
        labels_2(i) = "HVHA";
    elseif (valence_labels(i) == 1 && arousal_labels(i) == 0)
        labels_2(i) = "HVLA";
    elseif (valence_labels(i) == 0 && arousal_labels(i) == 1)
        labels_2(i) = "LVHA";
    else
        labels_2(i) = "LVLA";
    end        
end

%% Visualizing Features
figure(1);
varnames = {'Delta' 'Theta' 'Slow Alpha' 'Alpha' 'Beta' 'Gamma' 'mean' 'std' 'kurtosis' 'skewness' 'entropy' 'energy'};
gplotmatrix(features_array,[],labels_2',['b' 'r' 'g' 'k'],[],[],'on','grpbars',varnames, varnames);
%gplotmatrix(features_array,[],labels(:,2),['k' 'r'],[],[],'on','grpbars',varnames, varnames);

%% Feature Selection
partition = cvpartition(labels(:,1), 'KFold', 10);
options   = statset('display', 'iter');

criterion = @(XT,yT,Xt,yt) ...
      (sum(yt ~= classify(Xt,XT,yT, 'quadratic')));

[fs,history] = sequentialfs(criterion,features_array,labels(:,1),'direction', 'backward', 'cv',partition,'options',options);
