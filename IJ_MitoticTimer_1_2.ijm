//Mitotic Timer
//This macro helps quantifying mitotic timing
 
  Quantification = getDirectory("Quantification");
  if (Quantification=="")
      exit("No temp directory available");
 
//What condition are you analyzing?
Dialog.create("Parameters");
items = newArray("NT", "Taxol", "Nocodazole");
Dialog.addRadioButtonGroup("Condition", items, 1, 3,"NT");
//Dialog.addNumber("Minutes per frame:", 3); // Removed in version 1.2
Dialog.addCheckbox("Save single cells?", false);
Dialog.show();
SavingOption = Dialog.getCheckbox();
//FrameTime = Dialog.getNumber(); // Removed in version 1.2
condition = Dialog.getRadioButton();
 
 
//Preliminary Settings
roiManager("reset");
run("Collect Garbage");
run("Clear Results");
//run("Close All");
 
print("\\Clear");
setTool("rectangle");
 
 
 
//Open an image
waitForUser("Open an Image");
wait(10);
 
//Remove Extension
  x = getTitle();
  x = replace(x, ".tif", "");      
  x = replace(x, ".tiff", "");    
  x = replace(x, ".lif", "");    
  x = replace(x, ".lsm", "");  
  x = replace(x, ".czi", "");    
  x = replace(x, ".nd2", "");
  x = replace(x, ".sld", "");
  x = replace(x, ".ome", "");
  title = x;
  print(title);
 
 
 
//remove scale
run("Set Scale...", "distance=0");
run("Select None");
getDimensions(width, height, channels, slices, frames);
rename("WorkingImage");
 
 
 
//This section allows to select cell by cell
    setTool("multipoint");
    run("Point Tool...", "type=Hybrid color=Yellow size=Medium label show counter=0");
    waitForUser("Please select center points for all areas of interest. Click OK when done");
    run("Clear Results");
    run("Set Measurements...", "centroid stack redirect=None decimal=3");
    run("Measure");
 
    for (i=0; i<nResults; i++) {
             slice = getResult("Slice", i);
                        px = getResult("X",i);
                        py = getResult("Y",i);
                        setSlice(slice);
//this will select an ROI around the mitotic cell
//the withd of the square is 180 pixels, calculations are made
//accordingly, 0.707 represents cos(45°); 127.28 = sqrt(2*(90^2))             
                        makeRectangle(round(px - (127.28*0.707)), round(py - (127.28*0.707)), 240, 240);
//makeRectangle(px-160, py-160, 320, 320); //the coordinates index from the top left, like a 2D array
             roiManager("Add");
             run("Select None");
    }
 
run("Clear Results");
print("Cell" + " \t " + "NEBD" + " \t " + "Metaphase" + " \t " + "Anaphase" + " \t " + "NEBD_to_Meta" + " \t " + "NEBD_to_Ana" + " \t " + "Comments");
setForegroundColor(255, 255, 255);
MitoticCells = roiManager("count");
 
for (MitoCell = 0; MitoCell < MitoticCells; MitoCell ++) {
            selectWindow("WorkingImage");
            roiManager("select", MitoCell);
            roiManager("rename", "Cell_" + MitoCell);
            run("Set Measurements...", "centroid stack redirect=None decimal=3");
            run("Measure");
            frame = getResult("Slice", 0);
            run("Clear Results");
            first_Frame = frame - 20;
            last_Frame = frame + 20;
 
//careful here, sometimes Fiji seems to confuse frames and slices
            if (first_Frame <= 0) {
                        first_Frame = 1;}
            if (last_Frame > nSlices){
                        last_Frame = nSlices;}
            if (condition == "Taxol") {
                        last_Frame = frames;}
            if (condition == "Nocodazole") {
                        last_Frame = frames;}
 
            //tot_Frames = last_Frame - first_Frame;
 
 
            run("Duplicate...", "title=ToClose duplicate range=first_Frame-last_Frame");
            run("Label...", "format=0 starting=["+first_Frame+"] interval=1 x=5 y=20 font=36 text=[] range=first_Frame-last_Frame");
            //run("Make Montage...", "columns=tot_Frames rows=1 scale=1 border=2 label use");
            setTool("hand");
            run("In [+]");
            run("In [+]");
            run("In [+]");
                                                Comments = "None";
            Dialog.createNonBlocking("MitoticTiming");
            Dialog.addNumber("NEBD:",  000);
            Dialog.addNumber("Metaphase:", 000);
            Dialog.addNumber("Anaphase:", 000);
            Dialog.addString("Comments:", Comments);
            Dialog.show();
            NEBD = (Dialog.getNumber());
            Meta = (Dialog.getNumber());
            Ana = (Dialog.getNumber());
            Comments = Dialog.getString();
            NEBD_to_Meta = Meta - NEBD;
            NEBD_to_Ana = Ana - NEBD;
 
            if (SavingOption == true){
                        saveAs("Tiff", Quantification + title + "_Cell_" + MitoCell);}
 
            print("Cell_" + MitoCell + " \t " + NEBD + " \t " + Meta + " \t " + Ana + " \t " + NEBD_to_Meta + " \t " + NEBD_to_Ana+ " \t " + Comments);
            if(isOpen("ToClose")){
                        selectWindow("ToClose");
                        run("Close");}
 
            if(isOpen("Montage")){
                        selectWindow("Montage");
                        run("Close");}
 
            selectWindow("Log");
            saveAs("Text", Quantification + title + ".txt");
            roiManager("Save", Quantification + "ROIs_" + title + ".zip");
            }
 
selectWindow("Log");
saveAs("Text", Quantification + title + ".txt");
roiManager("Save", Quantification + "ROIs_" + title + ".zip");
