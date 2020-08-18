package io.opencaesar.docbook.adapter;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Class that implements DBTransform 
 * Used for tag replacement and creates PDF and HTML extension XSLs
 */
public class TagTransform extends DBTransformer {
	private String framePath;
	private String docPath; 
	private boolean save;
	
	/**
	 * Tag Transform constructor
	 * @param inputPath file path to the input docbook whose tags will be replaced
	 * @param stylePath file path to the tag replacement stylesheet 
	 * @param resultPath file path to the resulting docbook
	 * @param frame file path to a dir holding the necessary frames used in tag replacement 
	 * @param doc file path to the dir holding the original docbook XSLs 
	 * @param saveArg boolean that determines whether we save the files we generate at src-gen/data
	 */
	public TagTransform (String inputPath, String stylePath, String resultPath, String frame, String doc, boolean saveArg) {
		super(inputPath, stylePath, resultPath);
		if (frame.equals("")) {
			LOGGER.info("Warning! No path to frame directory was given. Can cause errors during tag replacement if a tag needing a frame was used."); 
		}
		if (doc == null) {
			exitPrint("For tag transformation the -o parameter is required");
		}
		framePath = frame;
		docPath = doc;
		save = saveArg;
	}

	@Override
	public void apply() {
		//In the given result folder, create a data folder
		//src-gen/data: holds data that the pdf and html xsl will reference. Will be deleted on exit
		String srcGen = getResult().getParentFile().getAbsolutePath().toString();
		//Create src-gen/data
		File dataDir = new File(srcGen + File.separator + "data");
		if (dataDir.exists()) {
			LOGGER.info("Overwriting data in src-gen/data");
		} else {
			if (!dataDir.mkdir()) {
				//Cannot make data dir 
				exitPrint("Cannot make src-gen/data. Exiting");
			}
		}
		String dataPath = dataDir.toURI().toString();
	
		/**
		 * Tag replacement: Set necessary params
		 * Creates the DocBook with tags replaced
		 * Creates data files that the PDF and HTML extension XSLs will reference
		 * Currently used params for tag replacement:
		 * framePath: file path to the frames that are used for the queries 
		 * currDate: current date in MM/dd/YYYY format
		 * dataPath: file path to the src-gen/data folder
		 */
		HashMap<String, String> params = new HashMap<String, String>();
		File frameFolder = getFile(framePath); 
		String framePath = frameFolder.toURI().toString();
		params.put("framePath", framePath);
		LocalDate date = LocalDate.now();
		DateTimeFormatter format = DateTimeFormatter.ofPattern("MM/dd/YYYY");
		String currDate = date.format(format); 
		params.put("currDate", currDate);
		params.put("dataPath", dataPath);
		applyWithParams(getInput(), getStyle(), getResult(), params); 
		params.clear();
		
		/**
		 * PDF extension XSL
		 * Creates pdf_ext.xsl which is the xsl file that renders the docbook into PDF 
		 * Also copy the necessary additional XSLs (pdf_title.xsl)
		 * Currently used params:
		 * dataPath: file path to tag_gen/data, which holds data files created in the tag replacement step (added in createExt func)
		 * originalPath: file path to the original DocBook XSL file that renders the docbook into XML-FO (which is then processed into PDF) (added in createExt func)
		 */
		createExtension("pdf", srcGen, dataPath, params);
		params.clear();
		
		/**
		 * HTML extension XSL
		 * Creates html_ext.xsl which is the xsl file that renders the docbook into html 
		 * Currently used params:
		 * data_loc: file path to tag_gen/data, which holds data files created in the tag replacement step 
		 * original_loc: file path to the original DocBook XSL file that renders the docbook into html
		 */
		createExtension("html", srcGen, dataPath, params);
		
		// Delete the no longer needed data files in tag_gen/data unless the save arg is set
		if (!save) {
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
		} else {
			LOGGER.info("Data files will be saved to src-gen/data");
		}
	}
	
	/**
	 * Creates the extension XSLs that extend the original docbook XSLs 
	 * @param type type of extension being created i.e. fo (pdf) or html
	 * @param srcGen dir of src-gen 
	 * @param dataPath dir of src-gen/data
	 * @param params hashMap containing key:param-name value:param-value
	 */
	private void createExtension(String type, String srcGen, String dataPath, HashMap<String, String> params) {
		// Add the dataPath param which points to src-gen/data
		params.put("dataPath", dataPath);
		// Convert the type from pdf -> fo if necessary 
		String originalType = type.equals("pdf") ? "fo" : type; 
		// Add the originalPath param which points to the original XSL that is being extending 
		File xsl = getFile(docPath + File.separator + originalType + File.separator + "docbook.xsl");
		String originalPath = xsl.toURI().toString();
		params.put("originalPath", originalPath);
		
		/* 
		 * Get to the targeted dir relative to the tag_transformation style sheet (passed in through -x)
		 * Expected file hierarchy 
		 * stylesheet-gen
		 * 		- tag
		 * 			- {stylesheet passed in}
		 * 		- {type} 
		 * 			- {target.xsl} 
		 */
		String styleSheetDir = getStyle().getParentFile().getParent();
		File targetDir = new File(styleSheetDir + File.separator + type);
		if (!targetDir.exists()) {
			// Stylesheet not found 
			LOGGER.error(type + " dir was not found. Expected to be at (relative to the passed in tag stylesheet): ../" + type);
			System.exit(1);
		}
		String targetPath = targetDir.getPath();
		// In the style sheet dir, get the input file (type_base.xsl) and the XSL (type_trans.xsl)
		File base = getFile(targetPath + File.separator + type + "_base.xsl");
		File trans = getFile(targetPath + File.separator + type + "_trans.xsl");
		
		//Create dir for the targeted type's outputs in src-gen/{type}
		File outputDir = new File(srcGen + File.separator + type); 
		if (outputDir.exists()) {
			LOGGER.info("Overwriting files in src-gen/" + type);
		} else {
			if (!outputDir.mkdir()) {
				exitPrint("Cannot create srcGen/" + type + " dir. Exiting");
			}
		}
		
		//Create output extension XSL and replace it if it exists prior
		File ext = new File(outputDir + File.separator + type + "_ext.xsl");
		if (ext.exists()) {
			ext.delete(); 
		}
		try {
			ext.createNewFile();
		} catch (IOException e) {
			LOGGER.error("Cannot create resulting file. Printing stack trace: \n ");
			e.printStackTrace();
			System.exit(1);
		}
		
		//Apply XSL to create the extension XSL output
		applyWithParams(base, trans, ext, params);
		
		/*
		 * Copy the necessary additional XSLs used in the extension file. 
		 * Files to be copied should be located in path/to/stylesheets/{type}/data_files
		 * Files are:
		 * {type}.title.xsl
		 */
		File titleIn = getFile(targetPath + File.separator + "data_files" + File.separator + type + "_title.xsl");
		File titleOut = new File(outputDir + File.separator + type + "_title.xsl");
		copy(titleIn, titleOut);
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
	
	// Copy resource file from jar to outside of jar 
	private void copy(File input, File dest) {
		try {
            Files.copy(input.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            LOGGER.error("Cannot copy the file: " + input.toString() + ". Printing stack trace \n");
            e.printStackTrace();
        }
	}
}
