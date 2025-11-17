function [Fval,pval] = classic_manova(D,A,J)
% FORMAT [Fval,pval] = classic_manova(D,A,J)
%
% D         [r x N] independent variable matrix with N data exemplars
% A         [d x N] dependent variable matrix
% J         number of DVs to use (must have J <= d)         
%
% Fval      [3 x 1] vector containing F-values for main effect var1, var2, interaction
% pval      [3 x 1] vector containing p-values for main effect var1, var2, interaction
%
% Implements 2-by-2 MANOVA using matlab stats toolbox 
% Code assumes entries in D are in order [A1 A2 B1 B2] where 
% factor 1 has levels A and B and factor 2 has levels 1 and 2 

var1 = [0 0 1 1]*D;  % get original variable 1
var2 = [0 1 0 1]*D;  % get original variable 2
v1 = var1';
v2 = var2';

Y = A';

% Create data table
table_str = ['tbl = table('];
Ystr = [];
dstr = [];
dcstr = 'd1';
for j = 1:J,
    Ystr = [Ystr,'Y(:,',int2str(j),'),'];
    dstr = [dstr,'"d',int2str(j),'" '];
    if j > 1
        dcstr = [dcstr,',d',int2str(j)];
    end
end

table_str = ['tbl = table(',Ystr,'v1,v2,VariableNames=[',dstr, '"v1" "v2"]);'];
%disp(table_str);
eval(table_str);

% Run MANOVA
maov_str = ['maov = manova(tbl,"',dcstr,' ~ v1 + v2 + v1*v2");'];
%disp(maov_str);
eval(maov_str);

% groupmeans(maov,"v1")

Fval = maov.stats.F;
pval = maov.stats.pValue;