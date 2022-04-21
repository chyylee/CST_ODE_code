function analyze_Global_SS(ws_nm)
    load(ws_nm,'error_runs','LHSmatrix','odeSettings','paramMatrix','icMatrix')
    load('analytical-base.mat','numsp','S','Jmat','Type')
    LHSmat = paramMatrix;
    erid = error_runs;
        idx_error = NaN(size(erid));
        for i = 1:length(erid)
            idx_error(i) = erid{i}{1};
        end  
    LHSmat(idx_error,:) = [];

    StbleSS = cell(size(LHSmat,1),1);
    ALLSS = cell(size(LHSmat,1),1);
    eigSS = cell(size(LHSmat,1),1);

    parfor i = 1:size(LHSmat,1)
        params = LHSmat(i,:);
        [StableStates,Sval,eigvals,UnstableStates] = calc_SS_stability(numsp,params,S,Jmat,Type);

        StbleSS{i} = {StableStates};
        ALLSS{i} = {Sval};
        eigSS{i} = {eigvals};
    end

    %[poss_SS, mat, poss_SSnames, mat_names,mat_num,mat_code] = get_SS_info_3sp(StbleSS,true)


    %% 3) ANALYZE SS PATTERNS


    SS_vector = StbleSS;
    sp_nms = {'BV','Li','oLB'};

    poss_SSnames = {'Co-elim','BV','Li','oLB',...
            'BV&Li', 'BV&oLB', 'Li&oLB', 'BVLi&oLB'};
    poss_SS = strings(size(SS_vector,1),1);

    for i = 1:size(SS_vector,1)
        temp = SS_vector{i}{:};
        num_SS = size(temp,1);
        if num_SS == 0
            poss_SS(i) = "All Unstable";
        else
            flg = strcat(num2str(num_SS),'SS');
            fnm = [];
            for j = 1:num_SS
                stmp = temp(j,:) > 0;
                nm = strcat(sp_nms{stmp});
                if sum(stmp) > 1
                    nm = strcat(nm," or ");
                elseif sum(stmp) == 1
                    nm = strcat(nm," or ");
                else
                    nm = strcat('',nm);
                end
                fnm = strcat(fnm,nm);
            end
            cfnm = char(strcat(flg,": ",fnm));
            ffnm = cfnm(1:length(cfnm) - 4);
            poss_SS(i) = string(ffnm);
        end
    end

    tabulate(poss_SS)

    %% 4) COMPILE OUTPUT
    noUnstable = poss_SS; % remove unstable states
    noUnstable(contains(poss_SS,"Unstable")) = [];

    numUS = length(poss_SS) - length(noUnstable);

    out = tabulate(noUnstable);
    SS_names = out(:,1);
    SS_counts = [out{:,2}]';
    SS_percent = [out{:,3}]';

    idx1SS = contains(SS_names,'1SS');

    monosum = sum(SS_percent(idx1SS));
    multisum = sum(SS_percent(~idx1SS));

    % PLOT
    [v,i] = sort(SS_percent,'descend');
    n = length(v);

    bar(v)
    xticks(1:n)
    xticklabels(SS_names(i))
    xtickangle(270)
    hold on
    text(1:n,v,string(round(v,3)'),'vert','bottom','horiz','center'); 
    title(strcat(" SS-Configs (N = ", num2str(sum(SS_counts)),")",...
        " (",num2str(numUS), " no stable state)"))
    ylabel('Percent of Stable Steady-States')

    dim = [.65 .8 .2 .1];
    str = strcat("Mono-Stable: ", num2str(round(monosum,2))...
        , "%") + newline + strcat("Multi-Stable: ", num2str(round(multisum,2)), "%");
    annotation('textbox',dim,'String',str)

    %% Save File
    out_nm = strcat('SSConfig-Analysis');
    save(out_nm,'StbleSS','S','Jmat','Type','numsp','poss_SS','noUnstable',...
        'SS_names','SS_counts','SS_percent','monosum','multisum','numUS',...
        'LHSmatrix','odeSettings','paramMatrix','icMatrix','poss_SSnames',...
        'LHSmat','ws_nm')
end
