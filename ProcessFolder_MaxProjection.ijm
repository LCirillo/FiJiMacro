input = getDirectory("input");
output= getDirectory("output");
  roiManager("reset");
  run("Close All");
  run("Clear Results");
  
time1 = getTime();
setBatchMode(true);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Process Started:");
print(year + '/' + (month+1) + '/' + dayOfMonth + "_____" + hour + ':' + minute + ':' + second);
processFolder(input);



// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]));
			processFolder("" + input + list[i]);
		if(endsWith(list[i], ".dv"))
			processFile(input, output, list[i]);
	}
}
function processFile(input, output, file) {
	setBatchMode(true);
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	run("Bio-Formats Importer", "open=[" + input + list[i] + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
    imageTitle=getTitle();

    //remove extensions
  	x = getTitle();
 	x = replace(x, ".tif", "");        
  	x = replace(x, ".tiff", "");      
  	x = replace(x, ".lif", "");      
  	x = replace(x, ".lsm", "");    
  	x = replace(x, ".czi", "");      
  	x = replace(x, ".nd2", "");
  	x = replace(x, ".sld", "");
  	title = x;
  	
	//MaxProject
    run("Z Project...", "projection=[Max Intensity] all");
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(imageTitle + "    " + hour + ':' + minute + ':' + second);
       
	//Saving
	selectWindow("MAX_" + imageTitle);
	title= getTitle();
	saveAs("Tiff", "MAX_" + title);
	run("Clear Results");
	roiManager("reset");
    run("Close All");
    run("Collect Garbage");
}
      	
setBatchMode(false);
selectWindow("Log");
print("Process Ended:");
print(year + '/' + (month+1) + '/' + dayOfMonth + "_____" + hour + ':' + minute + ':' + second);
IJ.log("3D projection took " + (getTime()-time1) + " msec");
saveAs("Text", output + "Log_report" + ".txt");
