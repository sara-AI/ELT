classdef custom_ensemble
%%  Ensemble Learning Toolbox
%
%	A simple class/toolbox for creating custom classification ensemble
%	models.
%
%--------------------------------------------------------------------------
%
%   Properties:
%       models:
%           A list of trained models
%       learners:
%           A list of function callbacks (Statistics and Machine Learning
%           Toolbox)
%       features:
%           A list of features to be used by each model
%       stacking_learner:
%           A function callback (Statistics and Machine Learning Toolbox)
%
%   Methods:
%       custom_ensemble:
%           Creates an empty ensemble object
%       fit:
%           Trains the learners with provided data
%       predict:
%           Predicts the output for new data with the ensemble
%
%--------------------------------------------------------------------------
%
%   Version 0.3 - Copyright 2018
%
%       For new releases and bug fixing of this Tool Set please send e-mail
%       to the authors.
%
%--------------------------------------------------------------------------
%
%   Institution:
%       Optimization, Modeling and Control Systems Research Group
%
%       Graduate Program in Industrial and Systems Engineering - PPGEPS
%
%       Pontifical Catholic University of Paran� - Brazil.
%           <http://en.pucpr.br/>
%
%--------------------------------------------------------------------------
%
%	Authors:
%       Victor Henrique Alves Ribeiro
%           <victor.henrique@pucpr.edu.br>
%
    
    properties

        models = {} % Trained models' list
        
        learners = {} % Learners' list (callbacks)
        features = {} % Features' list
        
        meta_model = {} % Trained meta (stacking) model
        meta_learner = {} % Metal learner (callback)
    end
    
    methods
        
        % Fit ensemble
        function obj = fit(obj, X, Y)
            
            % Sanity check
            if nargin < 3
                error('No data')
            end
            
            % If no features have been defined, use all
            if isempty(obj.features)
                for i = 1 : length(obj.learners)
                    obj.features{i} = 1:size(X, 2);
                end
            end
            
            % Fit all learners
            for i = 1 : length(obj.learners)
                obj.models{i} = obj.learners{i}(X(:,obj.features{i}), Y);
            end
            
            % Fit stacking meta model
            if ~isempty(obj.meta_learner)
                
                % Predict for all models
                for i = 1 : length(obj.models)
                    y(:,i) = predict(obj.models{i}, X(:, obj.features{i}));
                end
                
                % Fit stacking model
                obj.meta_model = obj.meta_learner(y * 1.0, Y);
            end
        end
        
        % Predict new data
        function Y = predict(obj, X)
            
            % Sanity check
            if nargin < 2
                error('No data')
            end
            
            % Predict for all models
            for i = 1 : length(obj.models)
                y(:,i) = predict(obj.models{i}, X(:, obj.features{i}));
            end
            
            % Combine predictions
            if isempty(obj.meta_model)
                Y = sum(y, 2) >= size(y, 2)/2;
            else
                Y = predict(obj.meta_model, 1.0 * y);
            end
        end
    end
    
end

