%% Introduction and workspace cleanup
% This script uses a shapeworks file (.xlsx) selected by the user to
% generate a JMA folder containing all files required for static JMA. The
% main folder will contain a Mean_Models folder and a folder for each study
% group. Each study group folder contains subfolders for each patient. Each
% patient subfolder contains .stl files and .particle files for each bone
% in the study.

clear;clc; close all

%% Directory Setup
% This section prompts the user to locate the main shapeworks file that
% will be used to generate the JMA folder. It then asks for an output
% location for the folder, and, finally, asks them to select the study
% group to create a folder for. Multiple studies may be selected. The
% output folders will be named JMA_(study group name)

% This will need to be updated if the L drive changes, but it will default
% to the working directory if that happens. The code will still work.
[Shapeworks_Project.name,Shapeworks_Project.directory] = uigetfile('*.xlsx','Please select the Shapework project file','L:\Project_Data');

output.directory = uigetdir('L:\Project_Data','Please select the output folder for JMA group folder(s)');

Shapeworks_Project.table = readtable(Shapeworks_Project.directory + "\" + Shapeworks_Project.name);

% This line gets the column headers from the excel sheet
Shapeworks_Project.variableNames = Shapeworks_Project.table.Properties.VariableNames;

% This line finds all variable names (excel column headers) that contain
% "group" and uses the contains function logical output to index the group
% names from the variable list.
c

Shapeworks_Project.selectedStudyGroups = Shapeworks_Project.studyGroupNames(listdlg('ListString',Shapeworks_Project.studyGroupNames,"PromptString","Please select the study group(s) to create JMA folder(s) for"));

tic

% This code finds the columns in the table corresponding to values of
% interest.
Shapeworks_Project.selectedStudyGroupIndices = find(contains(Shapeworks_Project.variableNames,Shapeworks_Project.selectedStudyGroups));
Shapeworks_Project.shapeIndices = find(contains(Shapeworks_Project.variableNames,"shape"));
Shapeworks_Project.localParticleIndices = find(contains(Shapeworks_Project.variableNames,"local_particles"));
Shapeworks_Project.relevantFileIndices = sort([Shapeworks_Project.shapeIndices,Shapeworks_Project.localParticleIndices]);

% This code removes the particles' folder name for use later and replaces it
% with the patient folder name, the correct arrangement for JMA.
Shapeworks_Project.localParticleCorrectedFolderNames = extractBefore(string(Shapeworks_Project.table{:,Shapeworks_Project.shapeIndices}),'\') + "\" + extractAfter(string(Shapeworks_Project.table{:,Shapeworks_Project.localParticleIndices}),'\');

Shapeworks_Project.shapeNames = string(Shapeworks_Project.table{:,Shapeworks_Project.shapeIndices});

output.fileNames = [Shapeworks_Project.shapeNames,Shapeworks_Project.localParticleCorrectedFolderNames];

%% Output filenames and structure generation
% This section generates folder names and filenames for all files to be
% copied over. The main loop loops through the groups that have been
% selected in the previous listdlg box.

Loop_count = 1;
Group_names = cell([]);
Group_rows = cell([]);

for Study_group_index = Shapeworks_Project.selectedStudyGroupIndices
    % Input path generation
    Group_names{Loop_count} = unique(Shapeworks_Project.table.(string(Shapeworks_Project.variableNames(Study_group_index))));
    % This next line removes the empty cells from the group names
    Group_names{Loop_count} = Group_names{Loop_count}(Group_names{Loop_count}~="");
    for Group_index = 1:numel(Group_names{Loop_count})
        Group_rows{Loop_count,Group_index} = find(contains(Shapeworks_Project.table.(string(Shapeworks_Project.variableNames(Study_group_index))),Group_names{Loop_count}{Group_index}));
        Shapeworks_Project.fileNames{Loop_count,Group_index} = Shapeworks_Project.table(Group_rows{Loop_count,Group_index},Shapeworks_Project.relevantFileIndices);
        Shapeworks_Project.paths{Loop_count,Group_index} = Shapeworks_Project.directory + string(Shapeworks_Project.fileNames{Loop_count,Group_index}{:,:});
    end

    % Output path generation
    output.folderName(Loop_count,1) = output.directory + "\JMA_" + erase(Shapeworks_Project.variableNames(Study_group_index),"group_");
    output.groupSubfolderPaths{Loop_count,1} = output.folderName{Loop_count,1} + "\" + string(Group_names{Loop_count});
    for Output_group_index = 1:numel(output.groupSubfolderPaths{Loop_count})
        Group_rows{Loop_count,Output_group_index} = find(contains(Shapeworks_Project.table.(string(Shapeworks_Project.variableNames(Study_group_index))),Group_names{Loop_count}{Output_group_index}));
        output.paths{Loop_count,Output_group_index} = output.groupSubfolderPaths{Loop_count,1}{Output_group_index} + "\" + output.fileNames(Group_rows{Loop_count,Output_group_index},:);
    end
    Loop_count = Loop_count + 1;
end

%% Writing Output
% This section converts the input and output array of arrays into a n x 1
% array listing all filepaths to be copied in one variable and all
% filepaths to be copied to in another variable.

% Vertical concatenation of paths for easier indexing (the reshape might
% not be required, increases troubleshooting readability for me personally)
Shapeworks_Project.pathsVert = reshape(vertcat(Shapeworks_Project.paths{:}),[],1);
output.pathsVert = reshape(vertcat(output.paths{:}),[],1);

% We need to make folders for the new paths or MATLAB gets mad
output.pathFolders = fileparts(output.pathsVert);
cellfun(@(path) ~isfolder(path) && mkdir(path), unique(output.pathFolders));

% The actual copy operation
cellfun(@(source,destination) copyfile(source,destination,'f'), cellstr(Shapeworks_Project.pathsVert), cellstr(output.pathsVert), 'UniformOutput', false);

toc