setBatchMode(true);
dirIm=getDirectory("Please, select the folder of the images");
dirFinal=getDirectory("Please, select the folder to save tif images");

run ("Close All");

list=getFileList(dirIm);
for (i=0; i<list.length; i++){
	run("Bio-Formats Importer", "open=["+dirIm+list[i]+"] color_mode=Grayscale open_all_series view=Hyperstack stack_order=XYCZT");
	Imagelist=getList("image.titles");
	for (ii=0; ii<Imagelist.length; ii++){
		name=slashEraser(Imagelist[ii]);
		selectWindow(Imagelist[ii]);
		print(dirFinal+name);
		if (startsWith(name, "Overview")==false) saveAs("tiff", dirFinal+name);
		close();
	}
}


function slashEraser(name){
	pos=indexOf(name, "-");
	//a=substring(name, 0, pos);
	b=substring(name, pos+2, lengthOf(name));
	name=b;
	if (indexOf(name, "-")!=-1) name=slashEraser(name);
	return name;
}
