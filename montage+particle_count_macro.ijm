//This macro fixes the channel shift from the microscope used, makes a montage of the channels 
//and a merged image and analyzes the number of particles (representative of respective proteins) in each channel

//choose directories 
Source_Directory = getDirectory("Source Directory ");
Results_Directory = getDirectory("Results Directory "); 
list = getFileList(Source_Directory);
setBatchMode(false);

//iterates the macro across all images in the source directory 
for (i=0; i<list.length; i++) {
 	showProgress(i+1, list.length);
 	open(Source_Directory+list[i]);
	t=getTitle;
	t = replace(t, ".tif", "");   
	rename("Stack");
	run("8-bit");
	run("Stack to Images");

	// translation values were found/verified using fluorescent bead in same mounting conditions
	selectWindow("Stack-0002");
	run("Translate...", "x=4 y=2 interpolation=None"); 
	
	// makes and labels montage, scale will be set automatically from metadata stored in images 
	run("Merge Channels...", "c1=Stack-0001 c2=Stack-0002 create keep");
	selectWindow("Composite");
	run("RGB Color");
	selectWindow("Composite");
	close();
	selectWindow("Stack-0001");
	run("Red");
	rename("Mei5");
	selectWindow("Stack-0002");
	run("Green");
	rename("Dmc1");
	selectWindow("Composite (RGB)");
	rename("Merge");
	run("Images to Stack", "name=Stack title=[] use"); 
	run("Make Montage...", "columns=3 rows=1 scale=1 border=2 font=36 label" );
	run("Scale Bar...", "width=2 height=4 font=14 color=White background=None location=[Lower Right] bold");

	//saves image file to results, and renames with original file name (which had date and timepoint in series)
	saveAs("Tiff", Results_Directory +"/Montage_"+t);
	selectWindow("Montage_"+t+".tif");
	close();

	//counts particles  
	selectWindow("Stack");
	run("8-bit");
	run("Stack to Images");
	selectWindow("Merge");
	close();
	selectWindow("Mei5");
	rename("Mei5 "+t); // renames file to include date and timepoint 
	run("Smooth"); // smooths image for thresholding 
	run("Threshold...");
	waitForUser("Set Threshold Values"); 
	//allows user to input threshold values, generally min=~10 and max=255, will vary slightly by sample background and brightness                   
	run("Make Binary");
	run("Watershed"); // splits particles that are close together that have been detected as a single large particle
	run("Analyze Particles...", "size=10-Infinity pixel summarize"); //counts the number of particles in given size range, exclused points too small to be protein
	selectWindow("Mei5 "+t);
	close();
	selectWindow("Dmc1");
	rename("Dmc1 "+t);
	run("Smooth");
	run("Threshold...");
	waitForUser("Set Threshold Values");  
	run("Make Binary");
	run("Watershed");
	run("Analyze Particles...", "size=10-Infinity pixel summarize");
	selectWindow("Dmc1 "+t);
	close();
}

close("*"); //closes remaining windows
selectWindow("Summary");
saveAs("Results", Results_Directory +"particle_count.csv"); // saves particle counts as CSV