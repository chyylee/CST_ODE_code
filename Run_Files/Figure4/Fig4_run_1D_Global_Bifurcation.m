%% Fig4_run_1D_Global_Bifurcation_Plots.m
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Goal: Assess how changing the growth rate of NO in a manner similar to an
% ABX perturbation impacts the predicted equilibrium behavior. This can be
% extended to any parameter in the model.
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% REQUIRED INPUTS:
%   * Model_LHS workspace
%
% REQUIRED FUNCTIONS
%   * SS_landscape_1D.m 
%       * calc_SS_stability
%       * get_SS_info_3sp.m
%   * Plot_1D_Global_Bifurcation.m
%
% OUTPUT:
%   * Folder with result of each parameter change
%   * Figure with results (frequency of each CST equilibrium behavior)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Christina Y. Lee
% University of Michigan
% Jan 22, 2022
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% 1. Load Required Datan and Enter Bifurcation Parameters
fdr_loc = '../workspaces';
load(strcat(fdr_loc,'/SSConfig-Analysis-Model_LHS_10x.mat'),'LHSmat',...
    'mat', 'S','Jmat','Type','colors', ...
    'param_names','all_nm','StbleSS')

% ###### Modify here #######
% Select Bifurcation Parameter
p = [1]; % growth of BV

% Define Range and Number of Iterations (plusx)
pmin = 0; % minimal value
pmax = -5; % maximal value
pnum = 30; % number of iterations
% ###### Modify here #######
%%
CST_state = {'1SS: [Li] CST-III';'1SS: [oLB] CST-I/II/V';'1SS: [NO] CST-IV';'2SS: [NO] CST-IV or [oLB] CST-I/II/V';'2SS: [Li] CST-III or [oLB] CST-I/II/V';'2SS: [Li] CST-III or [Li] CST-III';'2SS: [NO] CST-IV or [Li] CST-III';'3SS: [NO] CST-IV or [Li] CST-III or [oLB] CST-I/II/V';'2SS: [oLB] CST-I/II/V or [oLB] CST-I/II/V';'2SS: [NO] CST-IV or [NO] CST-IV'};
[indx,tf] = listdlg('ListString',CST_state);
sel_idx = [];
for i = 1:length(indx)
    tmp = all_nm == CST_state(indx(i));
    sel_idx = [sel_idx; find(tmp)];
end
sel_nets = LHSmat(sel_idx,:);
prepb = strrep(regexprep(CST_state{indx},{':','[',']','/'},{'-','','-',''}),' ','');
fdr_nm = strcat(prepb,'-',date);
mkdir(fdr_nm)

%% 2. Call 1D Bifurcation Code

% Parameter set range
num_st = 1;
num_iter = size(sel_nets,1);

% Run the global code
pn = p; pnmin = 0; pnmax = 0.1; pnumn = 2;
for i = num_st:num_iter
    net_id = i;
    base_params = sel_nets(net_id,:);
    disp('~~~~~~~~~~~~~~~~~~')
    disp(strcat("RUNNING: ", " SET #", num2str(net_id)))
    disp('~~~~~~~~~~~~~~~~~~')
    [SS_map,data_out,sum_table,svnm] = SS_landscape_1D(3,base_params,param_names,S,Jmat,Type,...
        colors,indx,pn,p,pnumn,pnum,pnmin,pnmax,pmin,pmax,net_id,fdr_nm);
end
%% 3. Plot Result (require folder name of results to run "fdr_nm")
Plot_1D_Global_Bifurcation(fdr_nm)