
	
	Dialog.create("Dif of Gaussians Filter");
	Dialog.addNumber("Min sigma: ",0);
	Dialog.addNumber("Max sigma: ", 50);
	Dialog.show();
	
	min1=Dialog.getNumber();
	max2=Dialog.getNumber();
	
	run("Duplicate...", "title=min duplicate");
	run("Gaussian Blur...", "sigma="+min1+" stack");
	run("Duplicate...", "title=max duplicate");
	run("Gaussian Blur...", "sigma="+max2+" stack");

	imageCalculator("Subtract stack", "min","max");
	selectWindow("max");
	close();
	selectWindow("min");
	rename("DifGauss");	