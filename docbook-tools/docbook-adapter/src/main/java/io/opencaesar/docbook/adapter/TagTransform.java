package io.opencaesar.docbook.adapter;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

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
		if (xsl == null) {
			exitPrint("For tag transformation the -x paramter is required");
		}
		xslPath = xsl; 
	}

	@Override
	public void apply() {
		//Create dir that holds the additional files created for pdf and html extensions
		//Tag_gen: holds the pdf and html xsl 
		String resultDir = getResult().getParentFile().getAbsolutePath().toString();
		LOGGER.info(resultDir);
		File tagGenDir = new File(resultDir + File.separator + "tag_gen"); 
		if (!tagGenDir.exists()) {
			tagGenDir.mkdir();
		} else {
			LOGGER.info("Tag gen exists");
		}
		File dataLoc = getFile(resultDir + File.separator + "tag_gen" + File.separator + "data");
		String dataPath = dataLoc.toURI().toString();
		
		//Tag replacement: Set necessary params
		//Creates the DocBook with tags replaced
		//Creates data files that the PDF and HTML extension XSLs will reference
		File frameFolder = getFile(framePath); 
		String framePath = frameFolder.toURI().toString();
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("framePath", framePath);
		applyWithParams(getInput(), getStyle(), getResult(), params); 
		params.clear();
		
		//PDF extension XSL
		File fo_base = getFile(Thread.currentThread().getContextClassLoader().getResource("tag_transformations/fo_base.xsl").getFile());
		File fo_trans = getFile(Thread.currentThread().getContextClassLoader().getResource("tag_transformations/fo_trans.xsl").getFile());
		File fo_ext = new File(tagGenDir + File.separator + "fo_ext.xsl");
		//Create extension XSL and replace it if it exists prior
		if (fo_ext.exists())
		{
			fo_ext.delete(); 
		}
		try {
			fo_ext.createNewFile();
		} catch (IOException e) {
			LOGGER.error("Cannot create resulting file. Printing stack trace: \n ");
			e.printStackTrace();
			System.exit(1);
		}
		//Get path of the original DocBook XSL for FO
		File fo_xsl = getFile(xslPath + File.separator + "fo" + File.separator + "docbook.xsl");
		String fo_path = fo_xsl.toURI().toString();
		params.put("data_loc", dataPath);
		params.put("original_loc", fo_path);
		applyWithParams(fo_base, fo_trans, fo_ext, params);
		params.clear();
		
		//HTML extension XSL
	}
}