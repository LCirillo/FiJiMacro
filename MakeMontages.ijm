input = getDirectory("RawData"); 
list = getFileList(input); 
output = getDirectory("Tiffs");

run("Close All");
print("\\Clear");
roiManager("reset");
run("Clear Results");
setBatchMode(true); 

for (i=0; i<list.length; i++) {
	open(input + list[i]);
	imageTitle = getTitle();
	imageTitle = replace(imageTitle, ".tif", "");
	rename(imageTitle);
	
	Stack.setChannel(1);
	setMinAndMax(600, 8000);
	Stack.setChannel(2);
	setMinAndMax(700, 20000);
	run("Label...", "format=00:00 starting=0 interval=30 x=5 y=20 font=60 text=[] range=1-43");
	run("Make Montage...", "columns=10 rows=1 scale=1 increment=4 border=3 use");
	while(!isOpen("Montage")) { wait(100); }
	
	selectImage("Montage");
	Property.set("CompositeProjection", "null");
	Stack.setDisplayMode("grayscale");
	
	saveAs("Tiff", output + "Montage_" + imageTitle + ".txt");
	run("Close All");
	run("Collect Garbage"); }
