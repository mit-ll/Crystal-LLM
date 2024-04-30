%DOMANE Program - Literature Review Meta Analysis
%Amanda Casale, G22

%Begin by formatting spreadsheet to match what is needed for this code OR
%read in the already-formatted spreadsheet:
%Casale_DOMANE_Sep2022_FormatCode 
%OR
[~,~,COVID] = xlsread('C:\Users\am21647\Desktop\CasaleUpdate_COVID220525.xls');
for i = 2:length(COVID(:,1))
    for j = [10 11]
        if COVID{i,j} == 0
            COVID{i,j} = 1;
        end
    end    
end

%Create different matrices for various patient populations:
    %Mild = Mild or outpatient or outpatient+hospitalized
    %Moderate = Moderate or hospitalized or outpatient+hospitalized
    %Severe = Critical or ICU or Severe or Severe-Critical
a = find(strcmp(COVID(:,5),'Mild'));
b = find(strcmp(COVID(:,5),'Outpatient'));
c = find(strcmp(COVID(:,5),'Outpatient+Hospitalized'));
d = find(strcmp(COVID(:,5),'Moderate'));
e = find(strcmp(COVID(:,5),'Hospitalized'));
f = find(strcmp(COVID(:,5),'Severe'));
g = find(strcmp(COVID(:,5),'Severe-Critical'));
h = find(strcmp(COVID(:,5),'Critical'));
i = find(strcmp(COVID(:,5),'ICU'));
Mild = COVID([1;a;b;c],:);
Moderate = COVID([1;c;d;e],:);
Severe = COVID([1;f;g;h;i],:);
clear a b c d e f g h i j
PatientPopulations = {'Mild','Moderate','Severe'};

DataSet.FullCOVID = COVID;
DataSet.Mild = Mild;
DataSet.Moderate = Moderate;
DataSet.Severe = Severe;
clear COVID Mild Moderate Severe

%Conduct network meta-analysis for each patient population-endpoint pair
for pp = 1:length(PatientPopulations)
    pop = PatientPopulations{pp};
    disp(pop)
    PP = DataSet.(pop);
    Endpoints = unique(PP(2:end,9));
    for ep = 1:length(Endpoints)
        EP = Endpoints{ep};
        disp(EP)			% disp = display value
        a = find(strcmp(PP(:,9),EP));
        temp = PP([1;a],:);
        [a,b] = sort(temp(2:end,1)); b = b + 1;
        temp = temp([1;b],:);
        clear a b
        
        %If there is more than one study for a given drug within the
        %patient population/endpoint set, conduct inverse-variance method
        for mmm = length(temp(:,1)):-1:2
            drug = temp{mmm,1};
            aa = find(strcmp(temp(:,1),drug));
            if length(aa) > 1
                for i = 1:length(aa)
                    a(i) = temp{aa(i),10};                    % Treated events
                    b(i) = temp{aa(i),6}-temp{aa(i),10};      % Number treated - treated events
                    c(i) = temp{aa(i),11};                    % Control events
                    d(i) = temp{aa(i),7}-temp{aa(i),11};      % Number controls - control events
                    n(i) = temp{aa(i),6}+temp{aa(i),7};       % N = number treated + number controls
                end
                Q = 0; R = 0; V = 0;
                for i = 1:length(aa)
                    Q = Q + (a(i)*d(i)/n(i));
                    R = R + (c(i)*b(i)/n(i));
                    V = V + (((a(i)+b(i))*(c(i)+d(i))*(a(i)+c(i))*(b(i)+d(i)))/(n(i)*n(i)*(n(i)-1)));
                end
                OR = Q/R;
                OR = log(1/OR);
                SE = sqrt(V/(Q*R));
                Min = OR-1.96*SE;
                Max = OR+1.96*SE;
                temp{aa(1),2} = 'Combo';
                temp{aa(1),3} = 'Combo';
                temp{aa(1),4} = 'Combo';
                temp{aa(1),6} = sum([temp{aa,6}]);
                temp{aa(1),7} = sum([temp{aa,7}]);
                temp{aa(1),10} = sum([temp{aa,10}]);
                temp{aa(1),11} = sum([temp{aa,11}]);
                temp{aa(1),12} = NaN;
                temp{aa(1),13} = OR;
                temp{aa(1),14} = NaN;
                temp{aa(1),15} = NaN;
                temp{aa(1),16} = NaN;
                temp{aa(1),17} = SE;
                temp{aa(1),18} = Min;
                temp{aa(1),19} = Max;
                aa(1) = [];
                temp(aa,:) = [];
            end
            clear drug aa i a b c d n Q R V OR SE Min Max
        end
        clear mmm
        
        %Visualize distributions of logOR and CIs:
        figure
        for i = 2:length(temp(:,1))
            pd = makedist('Normal','mu',temp{i,13},'sigma',temp{i,17});
            x = -10:0.001:10;
            y = pdf(pd,x);
            plot(x,y)
            hold on
            clear pd x y
        end
        legend(temp(2:end,1))
        xlabel('Log Odds Ratio and CI')
        title([pop ' Patient Population and ' EP ' Endpoint'])
        
        %Visualize as 1,000,000 points:
        n = 1000000;
        figure
        for i = 2:length(temp(:,1))
            pd = makedist('Normal','mu',temp{i,13},'sigma',temp{i,17});  % LogOddsi(13) SE_LogOdds(17)
            r(:,i) = random(pd,n,1);
            histogram(r(:,i),100,'Normalization','pdf')
            hold on
            clear pd
        end
        xlim([-10 10])
        legend(temp(2:end,1))
        xlabel('Log Odds Ratio and CI')
        title([pop ' Patient Population and ' EP ' Endpoint'])
        r(:,1) = [];
        for i = 1:length(r(:,1))
            [~,b] = sort(r(i,:),'descend');      % ~ indicates that you want the second output, not the first one from sort function; b has the index of sorted elements
            b(2,:) = 1:length(b);
            r(i,b(1,:)) = b(2,:);
            clear b
        end
        for i = 1:length(r(1,:))
            for j = 1:length(r(1,:))
                rank(i,j) = length(find(r(:,j)==i));
            end
        end
        rank = rank/n;    
        
        figure
        for i = 1:length(rank(1,:))
            plot(1:length(rank(:,1)),rank(:,i))
            hold on
        end
        xlim([0.5 length(rank(1,:))+0.5])
        set(gca,'XTick',1:1:length(rank))
        legend(temp(2:end,1))
        xlabel('Rank')
        ylabel('Probability of Rank')
        ylim([0 1])
        title([pop ' Patient Population and ' EP ' Endpoint'])
        
        for j = 1:length(rank(1,:))
            for i = length(rank(:,1)):-1:2
                rank(i,j) = sum(rank(1:i,j));
            end
            Sol(j) = trapz(rank(:,j));		% Trapezoidal numberical integration
        end
        Sol = Sol/(length(temp(:,1))-2);
        [a,b] = sort(Sol,'descend');
        b(2,:) = 1:length(b);
        Sol = num2cell(Sol);
        Sol(2,:) = temp(2:end,1);
        Sol(3,b(1,:)) = num2cell(b(2,:));
        Sol(4,:) = temp(2:end,13);
        Sol(5,:) = temp(2:end,3);
        Sol(6,:) = temp(2:end,4);
        Sol(7,:) = temp(2:end,22);
        
        Sol = transpose(Sol);
        [a,b] = sort(cell2mat(Sol(:,3)));
        Sol = Sol(b,:);
        Sol = Sol(:,[2 4 7 6 5 1 3]);       
        DataSet.Solutions.(pop).(EP) = Sol;
        clear EP i j rank Prioritize Sol temp a b r
    end
    clear ep pop PP Endpoints
end
clear pp PatientPopulations

%Make bar plots
for pp = 1:length(fields(DataSet.Solutions))
    pop = fields(DataSet.Solutions);
    pop = pop{pp};
    for ep = 1:length(fields(DataSet.Solutions.(pop)))
        EP = fields(DataSet.Solutions.(pop));
        EP = EP{ep};
        for i = 1:length(DataSet.Solutions.(pop).(EP)(:,1))
            if length(DataSet.Solutions.(pop).(EP){i,1}) > 25
                DataSet.Solutions.(pop).(EP){i,1} = DataSet.Solutions.(pop).(EP){i,1}(1:25);
            end
        end        
        figure
        bar(cell2mat(DataSet.Solutions.(pop).(EP)(:,6)));
        set(gca,'XTick',1:length(DataSet.Solutions.(pop).(EP)(:,6)),'XTickLabel',DataSet.Solutions.(pop).(EP)(:,1))
        xtickangle(315)
        ylabel('SUCRA Value')
        title(['SUCRA Values for ' pop ' Population with ' EP ' Endpoint'])
        ylim([0 1])
    end
end
clear pop pp ep EP n
