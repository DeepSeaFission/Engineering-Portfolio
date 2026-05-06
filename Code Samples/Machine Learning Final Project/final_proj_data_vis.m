%% Data Processing
% By Jordan Langford

clear;clc;close all

%% Data Import

raw.data = readtable("bone-marrow.txt");

raw.headers = ["Recipient Gender" "Stem Cell Source" "Donor Age (Numeric)" "Donor Age (>35)" "IIIV" "Gender Match" "Donor Blood Type" "Recipient Blood Type" "Recipient Rh" "Blood Type Match" "CMV Status" "Infection Prior to Transplant" "Recipient CMV" "Disease Type" "Risk Group" "Relapse Tx" "Disease Malignancy" "HLA Match" "HLA Mismatch" "Antigen Differences" "Allele Differences" "HLAgrI" "Recipient Age" "Recipient Age (>10)" "Recipient Age Bracket" "Relapse" "Development of Acute Graft" "Chronic Graft" "CD34 to Mass Ratio" "CD3 to CD34 Ratio" "CD3 per Kg" "Body Mass" "ANC Recovery" "PLT Recovery" "Time to Graft Dev" "Survival Time (Numeric)" "Survival Status"];

raw.table = raw.data;
raw.table.Properties.VariableNames = raw.headers;

%% Data Set Selections

age.table = raw.table(:,["Survival Status" "Recipient Age" "Recipient Age (>10)" "Recipient Age Bracket" "Donor Age (Numeric)" "Donor Age (>35)"]);
blood.table = raw.table(:,["Survival Status" "Stem Cell Source" "Donor Blood Type" "Recipient Blood Type" "Blood Type Match" "CMV Status" "Recipient CMV" "Infection Prior to Transplant" "HLA Match" "HLA Mismatch" "Antigen Differences" "Allele Differences" "HLAgrI"]);
disease.table = raw.table(:,["Survival Status" "Disease Type" "Disease Malignancy" "Relapse"]);
graft.table = raw.table(:,["Survival Status" "IIIV" "Development of Acute Graft" "Chronic Graft" "Time to Graft Dev"]);
treatment.table = raw.table(:,["Survival Status" "CD34 to Mass Ratio" "CD3 to CD34 Ratio" "CD3 per Kg" "Body Mass" "ANC Recovery" "PLT Recovery"]);
misc.table = raw.table(:,["Survival Status" "Recipient Gender" "Gender Match" "Risk Group" "Relapse Tx"]);

%% Histogram Development

for var_index = 1:numel(raw.headers)
    try
        figure
        histogram(raw.table.(raw.headers(var_index)))
        title(raw.headers(var_index))
    catch pass
    end
end

%% 

index.survival = raw.table.("Survival Status");
data.bodymass = raw.table.("Body Mass");

figure
histogram(data.bodymass(logical(index.survival)))

%% Data Groomnig

data = raw.table;
data.("Recipient Blood Type")(isnan(data.("Recipient Blood Type"))) = mode(data.("Recipient Blood Type"));
data.("Recipient Rh")(isnan(data.("Recipient Rh"))) = mode(data.("Recipient Rh"));
data.("Blood Type Match")(isnan(data.("Blood Type Match"))) = mode(data.("Blood Type Match"));
data.("CMV Status")(isnan(data.("CMV Status"))) = mode(data.("CMV Status"));
data.("Infection Prior to Transplant")(isnan(data.("Infection Prior to Transplant"))) = mode(data.("Infection Prior to Transplant"));
data.("Recipient CMV")(isnan(data.("Recipient CMV"))) = mode(data.("Recipient CMV"));
data.("Recipient Blood Type")(isnan(data.("Recipient Blood Type"))) = mode(data.("Recipient Blood Type"));
data.("Antigen Differences")(isnan(data.("Antigen Differences"))) = mode(data.("Antigen Differences"));
data.("Allele Differences")(isnan(data.("Allele Differences"))) = mode(data.("Allele Differences"));
data.("Chronic Graft")(isnan(data.("Chronic Graft"))) = mode(data.("Chronic Graft"));
data.("CD3 to CD34 Ratio")(isnan(data.("CD3 to CD34 Ratio"))) = mean(data.("CD3 to CD34 Ratio")(~isnan(data.("CD3 to CD34 Ratio"))));
data.("CD3 per Kg")(isnan(data.("CD3 per Kg"))) = mean(data.("CD3 per Kg")(~isnan(data.("CD3 per Kg"))));
data.("Body Mass")(isnan(data.("Body Mass"))) = mean(data.("Body Mass")(~isnan(data.("Body Mass"))));

data.("Disease Type")(contains(data.("Disease Type"),'ALL','IgnoreCase',true)) = {'1'};
data.("Disease Type")(contains(data.("Disease Type"),'AML','IgnoreCase',true)) = {'2'};
data.("Disease Type")(contains(data.("Disease Type"),'lymphoma','IgnoreCase',true)) = {'3'};
data.("Disease Type")(contains(data.("Disease Type"),'chronic','IgnoreCase',true)) = {'4'};
data.("Disease Type")(contains(data.("Disease Type"),'nonmalignant','IgnoreCase',true)) = {'0'};

data.("Disease Type") = cellfun(@str2double,data.("Disease Type"));

%% Data Export

writetable(data,"main_data.xlsx")