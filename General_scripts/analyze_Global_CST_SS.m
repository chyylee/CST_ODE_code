function analyze_Global_CST_SS(fn)
    load(fn)
    all_nm = [];
    for idx = 1:length(StbleSS)
        run_mat = cell2mat(StbleSS{idx});
        [nmf] = get_VALENCIA_class(run_mat);
        all_nm = [all_nm; nmf];
    end

    tabulate(all_nm)

    % PLOT THE OUTPUT WITH NO-SS REMOVED
    poss_SSv = all_nm;

    noUnstablev = poss_SSv; % remove unstable states
    noUnstablev(contains(poss_SSv,"0SS")) = [];

    numUS = length(poss_SSv) - length(noUnstablev);

    out = tabulate(noUnstablev);
    SS_namesv = out(:,1);
    SS_countsv = [out{:,2}]';
    SS_percentv = [out{:,3}]';

    idx1SS = contains(SS_namesv,'1SS');

    monosum = sum(SS_percentv(idx1SS));
    multisum = sum(SS_percentv(~idx1SS));

    [v,i] = sort(SS_percentv,'descend');
    n = length(v);

    bar(v)
    xticks(1:length(v))
    xticklabels(SS_namesv(i))
    xtickangle(270)
    hold on

    text(1:n,v,string(round(v,3)'),'vert','bottom','horiz','center'); 
    ylabel('Percent of Stable Steady-States')

    dim = [.65 .8 .2 .1];
    str = strcat("Mono-Stable: ", num2str(round(monosum,2))...
        , "%") + newline + strcat("Multi-Stable: ", num2str(round(multisum,2)), "%");
    annotation('textbox',dim,'String',str)


    % 4. Append VALCENIA CST to data
    save(fn,'all_nm','SS_namesv','SS_percentv','SS_countsv',...
        '-append')
end