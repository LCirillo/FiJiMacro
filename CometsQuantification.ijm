  //This macro measures the number of EB3-Comets in single plane, 
  //time lapse images of C. elegans embryo.
  //It creates four different files and saves them in four folders, representative 
  //of the different image processing steps. The image used for quantification
  //is obtained applying a mask on the "Processed" image, and it is saved in the 
  //"Comets" folder. Identification of the single comets appear in the ROI manager
  //and can be saved. To minimize artifacts, double check the 
  //results applying the mask of the comets to the original image. 
  
  //Before starting create a folder where to save the outputs, the macro will request to 
  //locate such a folder
 
 run("Close All");

  // Get path to Save Data
  Quantification = getDirectory("Quantification");
  if (Quantification=="")
      exit("No temp directory available");

//Open the image
 waitForUser("Open an Image");
  imageTitle = getTitle();

//Remove Extension
  x = getTitle();
  x = replace(x, ".tif", "");        
  x = replace(x, ".tiff", "");      
  x = replace(x, ".lif", "");      
  x = replace(x, ".lsm", "");    
  x = replace(x, ".czi", "");      
  x = replace(x, ".nd2", "");
  title = x;

//Preliminary settings 
 run("Set Measurements...", "area mean redirect=None decimal=3");
 roiManager("reset");
 run("Clear Results");
 run("Select None");
 selectWindow(imageTitle);          
  
 // Create folders
  EmbryoMask = Quantification + "EmbryoMask" + File.separator;
  File.makeDirectory(EmbryoMask);
  if (!File.exists(EmbryoMask))
      exit("Unable to create directory");
  print("");
  print(EmbryoMask);
  
  NoBack = Quantification + "NoBack" + File.separator;
  File.makeDirectory(NoBack);
  if (!File.exists(NoBack))
      exit("Unable to create directory");
  print("");
  print(NoBack);

  Processed = Quantification + "Processed" + File.separator;
  File.makeDirectory(Processed);
  if (!File.exists(Processed))
      exit("Unable to create directory");
  print("");
  print(Processed);

  Comets = Quantification + "Comets" + File.separator;
  File.makeDirectory(Comets);
  if (!File.exists(Comets))
      exit("Unable to create directory");
  print("");
  print(Comets);


//Background Subtraction
	run("Grays");
	selectWindow(imageTitle); 
	run("Duplicate...", "duplicate");
	run("Smooth", "stack");
	run("Sharpen", "stack");
	run("Smooth", "stack");
	setAutoThreshold("Default dark");
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate");
	run("Erode", "stack");
	run("Dilate", "stack");
	run("Analyze Particles...", "size=200-Infinity circularity=0.50-1.00 add stack");
		//Saving the embryo mask
		saveAs("Tiff", EmbryoMask + title + ".tiff");
		close();
	selectWindow(imageTitle); 
	n = roiManager("count");
	for (i=0; i<n; i++) {
		roiManager('select', i);
		run("Measure", "slice");
		BG=getResult("Mean");
		run("Subtract...", "value=BG slice");	  
		setForegroundColor(0, 0, 0);
		setForegroundColor(0, 0, 0);
		run("Make Inverse");
		run("Fill", "slice");	  
		run("Clear Results");  
		   }
	run("Select None");
	roiManager("reset");
			//Saving the image with background subtraction
		    saveAs("Tiff", NoBack + title + ".tiff");
		    newTitle = getTitle();
			//Saving the results of Background subtration and Area	
		    saveAs("Results", NoBack + title + ".csv");
	run("Clear Results");
	
//Comets segmentation
	run("Duplicate...", "duplicate range=141-141");
	run("Measure", "slice");
	BG=getResult("Mean");
	close();
	selectWindow(newTitle); 
	run("Duplicate...", "duplicate");
	run("Subtract...", "value=BG stack");	
	run("Clear Results"); 
	run("Subtract Background...", "rolling=1.5 stack");
	run("Smooth","stack");
	run("Sharpen","stack");
	run("Smooth","stack");
	run("Sharpen","stack");
	run("Smooth","stack");
	run("Sharpen","stack");
	run("Enhance Contrast...", "saturated=0.2 process_all");
	run("Subtract Background...", "rolling=1 stack");
		//Save processed image
		saveAs("Tiff", Processed + title + ".tiff");
		setOption("BlackBackground", false);
	run("Convert to Mask", "method=RenyiEntropy background=Dark calculate");
	run("Analyze Particles...", "size=4-Infinity pixel summarize add stack");
		//Save Comets mask and results
		saveAs("Tiff", Comets + title + ".tiff");
		saveAs("Results", Comets + title + ".csv");
		roiManager("Save", Comets + title + ".zip");