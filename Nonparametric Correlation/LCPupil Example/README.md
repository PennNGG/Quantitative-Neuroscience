# Nonparametric correlation Matlab code.

1. Get data
The data should already be in the LCPupil Example folder, but it is also stored on Box. Steps 1a-1e are thus optional.
	a. It is in the NeuroCore class Box folder. https://upenn.app.box.com/
   	b. Path: NeuroCore/PupilLCData
   	d. The NeuroCore Box folder should have been shared with you during the course. Please let us know if you cannot find it.
	e.  Note the directory where it is on your computer if Box is mounted to your computer. Or save the file to your computer (ideally to the LCPupil Example folder if Box is not mounted)
   
2. Add  LCPupil Example folder to Matlab Path
	a. In Matlab (as of version 2019a), go to the HOME tab
	b. Find button "Set Path" and click on it
	c. Click on "Add Folder" Button
	c. Add the LCPupil Example folder
	d. Add the folder that contains the data from step 1 (if it is not saved in the LCPupil Example folder)
	e. Optional: Updated dependency functions are from https://github.com/TheGoldLab/Lab_Matlab_Utilities if you need them. However, they should already be in the LCPupil Example folder 

3. Optional: If the data from step 1 is not in the LCPupil Example folder, update the function getLCP_trialData to point to where you put the data.
	a. Change line 199 
	b. Line 199: dat = load('trialData'); 
	c. Change 'trialData' to the directory where you put the data from step 1.

4. Run function:
   figLCP_tonic