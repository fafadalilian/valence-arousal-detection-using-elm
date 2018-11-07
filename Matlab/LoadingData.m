%% Clear all/ close figs
close all 
clear
clc

%% Setting Parameters
PARTICIPANTS_NUM = 32;
VIDEOS_NUM       = 40;
%% Load Data
addpath(genpath('Matlab/TEAP-master'));

data_path = '~/Desktop/DEAP/MATLAB_data_preprocessed/';

if ~exist([data_path '/s30_eeglab.mat'],'file')
    loading_DEAP(data_path);
end 

feedbacks = readtable('~/Desktop/DEAP/participant_ratings.csv');

%% Extracting Features
for participant = 1:PARTICIPANTS_NUM
    eeglab_file = sprintf('%ss%0.2d_eeglab.mat', data_path, participant);
    disp(eeglab_file)
    bulk = Bulk_load(eeglab_file);
    
    for epoch = 1:VIDEOS_NUM
        %extracting EMG features
        [features(participant,epoch).EMG_feats, features(participant,epoch).EMG_feats_names] = EMG_feat_extr(bulk(epoch));
        %extracting EEG features
        [features(participant,epoch).EEG_feats, features(participant,epoch).EEG_feats_names] = EEG_feat_extr(bulk(epoch));
        %extracting GSR features
        [features(participant,epoch).GSR_feats, features(participant,epoch).GSR_feats_names] = GSR_feat_extr(bulk(epoch));
        %extracting BVP features
        [features(participant,epoch).BVP_feats, features(participant,epoch).BVP_feats_names] = BVP_feat_extr(bulk(epoch));
        %extracting respiration features
        [features(participant,epoch).RES_feats, features(participant,epoch).RES_feats_names] = RES_feat_extr(bulk(epoch));
        
        feedback = feedbacks(feedbacks.Participant_id==participant & feedbacks.Experiment_id==epoch,:);
        
        features(participant,epoch).feedback.felt_arousal     = feedback.Arousal;
        features(participant,epoch).feedback.felt_valence     = feedback.Valence;
        features(participant,epoch).feedback.felt_dominance   = feedback.Dominance;
        features(participant,epoch).feedback.felt_liking      = feedback.Liking;
        features(participant,epoch).feedback.felt_familiarity = feedback.Familiarity;
        fprintf('extracted all the features for subject %d epoch %d\n',participant, epoch);
    end
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

for particpant = 1:PARTICIPANTS_NUM
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
    end
end

features_array = [delta' theta' slow_alpha' alpha' beta' gamma'];
labels         = [valence_labels' arousal_labels' dominance_labels' liking_labels'];

%% Visualizing Features
figure(1);
varnames = {'Delta' 'Theta' 'Slow Alpha' 'Alpha' 'Beta' 'Gamma'};
gplotmatrix(features_array(:,[1 2]),[],labels(:,1),'br',[],[],'on','grpbars',varnames([1 2]), varnames([1 2]));