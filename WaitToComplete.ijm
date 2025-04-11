//IJ often proceeds with the code before completing a task,
//this command helps stalling the code until a certain task 
//is done


	run("Make Montage...", "columns=10 rows=1 scale=1 increment=4 border=3 use");
	while(!isOpen("Montage")) { wait(100); }
