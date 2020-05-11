
% open and close the win-tie-loss values file to clear previous one
winTieLossFile = fopen('winTieLossValuesMdMRE.txt','w');
fclose(winTieLossFile);

% take out each one of the saved workspaces for each one of the datasets
% define datasets of experiment
allMyDatasets = {...
        'cocomo81','cocomo81e','cocomo81o',...
        'nasa93','nasa93_center_2','nasa93_center_5',...
        'desharnais',...
        'sdr','albrecht','isbsg_banking'...
        };


for datasetCounter = 1:10
    % define datasets of experiment
allMyDatasets = {...
        'cocomo81','cocomo81e','cocomo81o',...
        'nasa93','nasa93_center_2','nasa93_center_5',...
        'desharnais',...
        'sdr','isbsg_banking'...
        };
    allMyMethods = {'TEAK','k=1','k=2','k=4','k=8','k=16','k=BestK','SLReg','NNet'};

    % open workspace
%     eval(['load leave_one_out_results_workspaces\',char(allMyDatasets(datasetCounter)),'.mat;']);
   eval(['load 10_by_3_way_results_workspaces\',char(allMyDatasets(datasetCounter)),'.mat;']);

    % open file to append
    winTieLossFile = fopen('winTieLossValuesMdMRE.txt','a');

    % define variables for mre values
    mre21 = mreGac2;
    mre22 = mre1;
    mre23 = mre2;
    mre24 = mre4;
    mre25 = mre8;
    mre26 = mre16;
    mre27 = mrex;
    mre28 = mreSLReg;
    mre29 = mreNNet;

    % indicate how many methods are being compared
    methodCount = 10;
    % define variables for win tie loss values
    win = zeros(methodCount,1);
    tie = zeros(methodCount,1);
    loss = zeros(methodCount,1);

    % start calculating win tie loss values
    for i = 1:methodCount

        for j = (i+1):methodCount

            if i ~= j   % if i and j are different

                for k = 1:size(mre1,1)
                    eval(['[P,H] = ranksum(mre2',num2str(i),'(',num2str(k),',:),mre2',num2str(j),'(',num2str(k),',:));']);
                    if H == 0   % if they are the same
                        eval(['tie(',num2str(i),') = tie(',num2str(i),') +1;']);
                        eval(['tie(',num2str(j),') = tie(',num2str(j),') +1;']);
                    else
                        % calculate median values
                        eval(['medi = median(mre2',num2str(i),'(',num2str(k),',:));']);
                        eval(['medj = median(mre2',num2str(j),'(',num2str(k),',:));']);
                        if medi < medj
                            eval(['win(',num2str(i),') = win(',num2str(i),') +1;']);
                            eval(['loss(',num2str(j),') = loss(',num2str(j),') +1;']);
                        else
                            eval(['win(',num2str(j),') = win(',num2str(j),') +1;']);
                            eval(['loss(',num2str(i),') = loss(',num2str(i),') +1;']);
                        end
                    end
                end

            end
        end
    end

    % calculate win minus loss and sort all the others according to it
    winMinusLoss = win - loss;
    [winMinusLoss sortedIndex] = sort(winMinusLoss, 'descend');
    allMyMethods = allMyMethods(sortedIndex);
    win = win(sortedIndex);
    tie = tie(sortedIndex);
    loss = loss(sortedIndex);

    % start writing the win-tie-loss values
    fprintf(winTieLossFile, [char(allMyDatasets(datasetCounter)) ',WIN,TIE,LOSS,WIN-LOSS\n']);
    for methodCounter = 1:methodCount
       fprintf(winTieLossFile, [char(allMyMethods(methodCounter))]);
       fprintf(winTieLossFile, [',' num2str(win(methodCounter))]);
       fprintf(winTieLossFile, [',' num2str(tie(methodCounter))]);
       fprintf(winTieLossFile, [',' num2str(loss(methodCounter))]);
       fprintf(winTieLossFile, [',' num2str(winMinusLoss(methodCounter)) '\n']);
    end
    % print an extra new line
    fprintf(winTieLossFile, '\n');
    % close file
    fclose(winTieLossFile);
    % remove the previously loaded workspace and clean command window
    clear;clc;

end
