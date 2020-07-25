package io.opencaesar.docbook.adapter;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Class that implements DBTransform 
 * Used for tag replacement and creates PDF and HTML extension XSLs
 * The extension XSLs will be placed in results/tag_gen
 * Requires the file path of the frames referenced in the tags
 * Requires the file path to the DocBook XSL folder
 */
public class TagTransform extends DBTransformer {
	private String framePath;
	private String xslPath; 

	public TagTransform (String inputPath, String stylePath, String resultPath, String frame, String xsl) {
		super(inputPath, stylePath, resultPath);
		if (frame == null) {
			exitPrint("For tag transformation the -f  paramater is required");
		}
		framePath = frame;
		xslPath= xsl;
	}

	@Override
	public void apply() {
		//In the given result folder, create tag_gen dir
		//tag_gen: holds the pdf and html xsl 
		//tag_gen/data: holds data that the pdf and html xsl will reference. Will be deleted on exit
		String resultDir = getResult().getParentFile().getAbsolutePath().toString();
		LOGGER.info(resultDir);
		File tagGenDir = new File(resultDir + File.separator + "tag_gen"); 
		if (!tagGenDir.exists()) {
			tagGenDir.mkdir();
		} else {
			LOGGER.info("Overwriting files in tag_gen");
		}
		//Create tag_gen/data. Exit operation if data dir exists (avoid accidently deleting user files)
		File dataDir = new File(tagGenDir.toString() + File.separator + "data");
		if (dataDir.exists()) {
			LOGGER.info("Please remove data from result/tag_gen. Operation exiting.");
			System.exit(1);
		}
		dataDir.mkdir();
		String tagGenPath = tagGenDir.toString();
		String dataPath = dataDir.toURI().toString();
		LOGGER.info(tagGenPath);
		LOGGER.info(dataPath);
		
		/**
		 * Tag replacement: Set necessary params
		 * Creates the DocBook with tags replaced
		 * Creates data files that the PDF and HTML extension XSLs will reference
		 * Currently used params for tag replacement:
		 * Framepath: file path to the frames that are used for the queries 
		 * currDate: current date
		 */
		HashMap<String, String> params = new HashMap<String, String>();
		File frameFolder = getFile(framePath); 
		String framePath = frameFolder.toURI().toString();
		params.put("framePath", framePath);
		LocalDate date = LocalDate.now();
		DateTimeFormatter format = DateTimeFormatter.ofPattern("MM/dd/YYYY");
		String currDate = date.format(format); 
		LOGGER.info(currDate);
		params.put("currDate", currDate);
		applyWithParams(getInput(), getStyle(), getResult(), params); 
		params.clear();
		
		//PDF extension XSL
		File foXSL = getFile(xslPath + File.separator + "fo" + File.separator + "docbook.xsl");
		String foPath = foXSL.toURI().toString();
		params.put("data_loc", dataPath);
		params.put("original_loc", foPath);
		createExtension("fo", tagGenPath, params);
		params.clear();
		
		//HTML extension XSL
		File htmlXSL = getFile(xslPath + File.separator + "html" + File.separator + "docbook.xsl"); 
		String htmlPath = htmlXSL.toURI().toString();
		params.put("data_loc", dataPath);
		params.put("original_loc", htmlPath); 
		createExtension("html", tagGenPath, params);
		
		//Delete the no longer needed data files in tag_gen/data
		try {
			deleteDir(dataDir); 
		} catch (IOException e) {
			LOGGER.error("Cannot delete dir"); 
			e.printStackTrace();
			System.exit(1);
		}
		if (!dataDir.delete()) {
			LOGGER.error("Canot delete data dir"); 
			System.exit(1);
		}
	}
	
	//Function to create the XSL extension files. (Ex: FO (PDF), HTML)
	private void createExtension(String type, String tagGen, HashMap<String, String> params) {
		//Get the base template and style sheet from tag_transformations resource folder
		File base = getFile(Thread.currentThread().getContextClassLoader().getResource("tag_transformations/" + type + "/" + type + "_base.xsl").getFile());
		File trans = getFile(Thread.currentThread().getContextClassLoader().getResource("tag_transformations/" + type + "/" + type + "_trans.xsl").getFile());
		//Create output extension XSL and replace it if it exists prior
		File ext = new File(tagGen + File.separator + type + "_ext.xsl");
		if (ext.exists())
		{
			ext.delete(); 
		}
		try {
			ext.createNewFile();
		} catch (IOException e) {
			LOGGER.error("Cannot create resulting file. Printing stack trace: \n ");
			e.printStackTrace();
			System.exit(1);
		}
		applyWithParams(base, trans, ext, params);
	}
	
	//Recursively delete a directory 
	private void deleteDir(File dir) throws IOException {
		for(File file: dir.listFiles()) {
			if (file.isFile()) {
				if (!file.delete()) {
					throw new IOException("Unable to delete file");
				}
			} else if (file.isDirectory()) {
				deleteDir(file);
			}
		}
	}
}




















