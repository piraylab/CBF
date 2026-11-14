function summary = analyze_all(source)
%ANALYZE_ALL Analyze completed Bird Task CBF fits and recovery results.
arguments
    source (1,:) char {mustBeMember(source,{'refit'})} = 'refit'
end
setup; p=cbf_paths();
if ~exist(p.results,'dir'),mkdir(p.results);end
summary=struct('additional',struct());
fprintf('1/5: Figure 1 synthetic dynamics.\n');
figure1_dynamics;
fprintf('2/5: Figure 2 parameter recovery.\n');
if analysis_inputs_available('recovery'),summary.recovery=figure2_recovery(source);end
if analysis_inputs_available('standard')
    fprintf('3/5: Average learning rate and Table 1.\n');
    summary.learning_rates=learning_rates(source);
    fprintf('4/5: Table 2 response times.\n');
    summary.response_times=response_times(source);
    fprintf('5/5: Figure 3 comparison and additional CBF analyses.\n');
    summary.additional=paper_additional(source);
else
    fprintf('SKIP Figure 3 CBF, learning rates and response times: Bird Task data and completed fits are required.\n');
end
save(fullfile(p.results,['analysis_summary_' source '.mat']),'summary','source');
fprintf('Analysis outputs and local working files saved in %s\n',p.results);
fprintf('Input requirements and coverage are listed in README.md.\n');
end
