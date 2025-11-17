function [X,res_std] = erp_baseline_correct (X,tims)
% Baseline correct
% FORMAT [X,res_std] = erp_baseline_correct (X,tims)

[S,C] = size(X);
[dS,dT] = size(X{1,1}) ;

% Indices of baseline data
ind = find(tims<=0);

method = 2;

switch method
    case 1
        % Over all subjects and conditions
        m = zeros(dS,1);
        for i=1:S
            for c=1:C
                m = m + mean(X{i,c}(:,ind),2);
            end
        end
        m = m/(S*C);

        % Subtract baseline
        for i=1:S,
            for c=1:C
                X{i,c}(:,ind) = X{i,c}(:,ind) - m*ones(1,length(ind));
            end
        end
    case 2
        % Within subject
        disp('Within-subject, within-condition baseline correction')
        for i=1:S
            for c=1:C
                m = mean(X{i,c}(:,ind),2);
                %X{i,c}(:,ind) = X{i,c}(:,ind) - m*ones(1,length(ind));
                X{i,c} = X{i,c} - m*ones(1,dT);

                mc = mean(X{i,c}(:,ind),2);
                res_std(i,c) = std(mc);
            end
        end
end



