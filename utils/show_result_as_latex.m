function show_result_as_latex(result_matrix, labels, compare_to)
%SHOW_RESULT_AS_LATEX Summary of this function goes here
%   Detailed explanation goes here
comp_id = find(strcmp(labels,compare_to));
comp_cost = result_matrix(comp_id, 1);
comp_ctps = result_matrix(comp_id, 2);
for i=1:size(result_matrix, 1)
    cost = result_matrix(i, 1);
    ctps = result_matrix(i, 2);
    fprintf('			{$ %s $} &%.0f &%.4f &%.1f\\%% & $\\times%.1f$ \\\\ \n', labels{i},...
    cost, ctps , comp_cost/cost*100 , comp_ctps/ctps);
end

