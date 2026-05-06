Readme

The main python code that performs the machine learning task is "Final_Project.py"
"main_data.xlsx" must be in the same directory, as this is the groomed dataset used for the machine learning process.
The data spreadsheet was created from the raw text file, which in turn was made by saving the .arff file as a .txt file.
MATLAB was used for data visualization and data grooming. The Excel spreadsheet was exported from MATLAB.
I have Samir's permission to use MATLAB for the data formatting, as I'm more familiar with working with it.

Set up a virtual environment through normal means and activate it.
Install the dependencies listed in "requirements.txt"
Run the main script either through an IDE or via 'python Final_Project.py'
As graphical windows for SCAP analysis are opened, close them to proceed with the script (the script pauses while the windows are open)

If desired, validate hyperparameter selection via 'python hyperparameter_search.py'