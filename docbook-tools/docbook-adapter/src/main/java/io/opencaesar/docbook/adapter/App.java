package io.opencaesar.docbook.adapter;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Appender;
import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import com.beust.jcommander.IParameterValidator;
import com.google.common.io.CharStreams;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.Configuration; 

import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.MimeConstants;

public class App {
	@Parameter(
		names = { "--input", "-i" },
		description = "DocBook file to apply the XSLT to (Required)",
		required = true,
		order = 1)
	String inputPath;
		
	@Parameter(
		names = { "--result", "-r" },
		description = "Path to the folder to save the result to (Required)",
		required = true,
		order = 2)
	String resultPath;
	
	@Parameter(
		names = { "--type", "-t" },
		description = "Type of operation. Options are tag, pdf, or html (Required)",
		validateWith = TypeValidator.class,
		required = true,
		order = 4)
	String type;
	
	@Parameter(
		names = { "--frames", "-f" },
		description = "Path to the folder to save the result to (Required for tag replacement, otherwise optional)",
		required = false,
		order = 5)
	String framePath = null;
	
	@Parameter(
			names = { "--xsl", "-x" },
			description = "Path to the DocBook XSLs (Required for tag replacement, otherwise optional)",
			required = false,
			order = 5)
	String xslPath = null;
	

	@Parameter(
		names = { "--fo", "-z" },
		description = "Option to save the intermediate FO representation for PDFs when using the PDF option (Optional)",
		required = false,
		order = 6)
	boolean fo = false;

	@Parameter(
		names = { "-d", "--debug" },
		description = "Shows debug logging statements",
		order = 9)
	private boolean debug;

	@Parameter(
		names = { "--help", "-h" },
		description = "Displays summary of options",
		help = true,
		order =10)
	private boolean help;
	
	private static String tag_path =  Thread.currentThread().getContextClassLoader().getResource("tag_transformations/all_transformations.xsl").getFile();
	private static String html_path =  "";//Thread.currentThread().getContextClassLoader().getResource("docbook_xsl/html/docbook.xsl").getFile();
	//private static String pdf_path = Thread.currentThread().getContextClassLoader().getResource("docbook_xsl/fo/docbook.xsl").getFile();
	private static String pdf_path = Thread.currentThread().getContextClassLoader().getResource("tag_transformations/fo_ext.xsl").getFile();
	
	private final Logger LOGGER = LogManager.getLogger("DocBook Adapter"); {
		LOGGER.setLevel(Level.INFO);
		PatternLayout layout = new PatternLayout("%r [%t] %-5p %c %x - %m%n");
		LOGGER.addAppender(new ConsoleAppender(layout));
	}

	public static void main(final String... args) {
		final App app = new App();
		final JCommander builder = JCommander.newBuilder().addObject(app).build();
		builder.parse(args);
		if (app.help) {
			builder.usage();
			return;
		}
		if (app.debug) {
			final Appender appender = LogManager.getRootLogger().getAppender("stdout");
			((AppenderSkeleton) appender).setThreshold(Level.DEBUG);
		}
	    try {
			app.run();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void run() throws Exception {
		LOGGER.info("=================================================================");
		LOGGER.info("                        S T A R T");
		LOGGER.info("                     DocBook Adapter " + getAppVersion());
		LOGGER.info("=================================================================");
		LOGGER.info("DocBook: " + inputPath);
		LOGGER.info("Result location: " + resultPath);
		//Get DBTransform class 
		DBTransform trans = getTransformer(inputPath, resultPath, type); 
		trans.apply();
		
	    LOGGER.info("=================================================================");
		LOGGER.info("                          E N D");
		LOGGER.info("=================================================================");
		}
	
	/**
	 * Get application version id from properties file.
	 * 
	 * @return version string from build.properties or UNKNOWN
	 */
	public String getAppVersion() {
		String version = "UNKNOWN";
		try {
			InputStream input = Thread.currentThread().getContextClassLoader().getResourceAsStream("version.txt");
			InputStreamReader reader = new InputStreamReader(input);
			version = CharStreams.toString(reader);
		} catch (IOException e) {
			String errorMsg = "Could not read version.txt file." + e;
			LOGGER.error(errorMsg, e);
			System.exit(1);
		}
		return version;
	}
	
	//Validate type parameter
	public static class TypeValidator implements IParameterValidator {
		@Override
		public void validate(final String name, final String value) throws ParameterException {
			final List<String> validTypes = Arrays.asList("pdf", "html", "tag");
			if (!validTypes.contains(value.toLowerCase())) {
				throw new ParameterException("Paramter " + name + " must be either pdf, html, or tag");
			}
		}
	}
	
	/**
	 * 
	 * Interface for Strategy design pattern
	 *
	 */
	public interface DBTransform{
		void apply(); 
	}
	
	/**
	 * Abstract superclass for Strategy design pattern
	 * @param inputPath: File path of the xml file to apply the style sheet to
	 * @param stylePath: File path of the xsl file that will be applied to the input
	 * @param resultPath: File path of the resulting file 
	 */
	abstract class DBTransformer implements DBTransform{
		private File input; 
		private File style; 
		private File result;
		
		public DBTransformer(String inputPath, String stylePath, String resultPath) {
			input = getFile(inputPath); 
			style = getFile(stylePath); 
			//Double check if input and result are the same (error if they are)
			result = new File(resultPath);
			if (result.getAbsoluteFile().equals(input.getAbsoluteFile()))
			{
				//Input and result are the same, return err msg and exit
				exitPrint("Error: Result and input are at the same location. Please change one"); 
			}
			//Create the resulting file and overwrite if it previously exists
			if (result.exists())
			{
				result.delete(); 
			}
			try {
				result.createNewFile();
			} catch (IOException e) {
				LOGGER.error("Cannot create resulting file. Printing stack trace: \n ");
				e.printStackTrace();
				System.exit(1);
			}
		}
		
		//Getter functions
		public File getInput() {
			return input;
		}
		
		public File getStyle() {
			return style;
		}
		
		public File getResult() {
			return result;
		}
		
		//Function to override
		public abstract void apply(); 		
	}
	
	/**
	 * Class that implements DBTransform.
	 * Used for HTML. Applies the appropriate XSL to get HTML format
	 */
	public class HTMLTransform extends DBTransformer {
		
		public HTMLTransform (String inputPath, String stylePath, String resultPath) {
			super(inputPath, stylePath, resultPath);
		}

		@Override
		public void apply() {
			applyTransformation(getInput(), getStyle(), getResult()); 
		}
	}
	
	/**
	 * Class that implements DBTransform
	 * Used for PDF transformation, as it has an intermediate transformation step
	 * XML to XML-FO to PDF
	 * Uses Apache FO to convert XML-FO to PDF
	 */
	public class PDFTransform extends DBTransformer {
		public PDFTransform(String inputPath, String stylePath, String resultPath) {
			super(inputPath, stylePath, resultPath); 
		}
		
		@Override
		public void apply() {
			//Create an intermediate file for the XML-FO transformation 
			try {
				File temp; 
				//If the fo arg is given, create the FO file and save it
				if (!fo) {
					temp = File.createTempFile("intermediate", ".xml", getResult().getParentFile());
					temp.deleteOnExit();
				} else {
					//Write over FO file if it exists
					String tempLoc = resultPath + File.separator + "fo.xml";
					temp = new File(tempLoc);
					if (temp.exists()) {
						temp.delete();
						temp.createNewFile();
					}
				}
				//Apply XML -> XML-FO transformation
				//applyTransformation(getInput(), getStyle(), temp);
				HashMap<String, String> params = new HashMap<String, String>(); 
				String ext = getResult().getParent() + "test_layer.xsl";
				params.put("ext", ext);
				applyWithParams(getInput(), getStyle(), temp, params); 
				LOGGER.info("Now apply FOP to PDF");
				//Apply XML-FO -> PDF transformation
				applyFOP(temp, getResult());
			} catch (IOException e) {
				LOGGER.error("File creation exception. Printing stack trace: \n ");
				e.printStackTrace();
				System.exit(1);
			}
			
		}
	}
	
	/**
	 * Class that implements DBTransform 
	 * Used for tag replacement and creates PDF and HTML extension XSLs
	 * The extension XSLs will be placed in results/tag_gen
	 * Requires the file path of the frames referenced in the tags
	 * Requires the file path to the DocBook XSL folder
	 */
	public class TagTransform extends DBTransformer {
		public TagTransform (String inputPath, String stylePath, String resultPath) {
			super(inputPath, stylePath, resultPath);
			if (framePath == null) {
				exitPrint("For tag transformation the -f  paramater is required");
			}
			if (xslPath == null) {
				exitPrint("For tag transformation the -x paramter is required");
			}
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
			File dataLoc = getFile(resultPath + File.separator + "tag_gen" + File.separator + "data");
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
		}
	}
	
	
	/**
	 * Creates an empty params and calls on applyWithParams, which does the work
	 */
	private void applyTransformation(File input, File style, File res) {
		HashMap<String, String> params = new HashMap<String, String>(); 
		applyWithParams(input, style, res, params);
	}
	
	/**
	 * Applies an XSLT on a given xml file using the Saxon HE XSL processor and sets a global param used in the XSLT
	 * @param input: File path of the input xml to apply the XSLT to
	 * @param sheet: File path of the XSL that will be applied
	 * @param result: File path of the resulting xml file
	 * @param params: HashMap<String, String>; key = paramName value = paramValue
	 */
	private void applyWithParams(File input, File style, File res, Map<String, String> params) {
		try {
			Configuration config = new Configuration(); 
			config.setXIncludeAware(true);
			Transformer transformer = new TransformerFactoryImpl(config)
					.newTransformer(new StreamSource(style));
			//Add parms to transformer
			params.forEach((key, value) -> {
				LOGGER.info(key + ": " + value);
				transformer.setParameter(key, value);
			});
			transformer.transform(new StreamSource(input), new StreamResult(res));
		} catch (TransformerException e) {
			LOGGER.error("Cannot apply transformation. Printing stack trace: \n");
			e.printStackTrace();
			System.exit(1);
		}
		
	}
	
	//Applies the FOP transformation that transform a XML-FO into PDF
	private void applyFOP(File input, File result) {
		FopFactory fopFact = FopFactory.newInstance();
		try {
			OutputStream out = new BufferedOutputStream(new FileOutputStream(result));
			Fop fop = fopFact.newFop(MimeConstants.MIME_PDF, out); 
			Transformer transformer = new TransformerFactoryImpl()
					.newTransformer();
			Source src = new StreamSource(input);
		    // Resulting SAX events (the generated FO) must be piped through to FOP
		    Result res = new SAXResult(fop.getDefaultHandler());
		    transformer.transform(src, res);
		    out.close();
		} catch (FOPException | TransformerException | IOException e) {
			LOGGER.error("Error: couldn't apply FOP transformation. Printing stack trace: \n"); 
			e.printStackTrace();
			System.exit(1);
		}
	}
	
	//Given a file path, return the file 
	private File getFile(String path) {
		File file = new File (path); 
		if (!file.exists()) {
			exitPrint("File does not exist at: " + path);
			return null;
		}
		return file;
	}
	
	//Print msg to log error and exit
	private void exitPrint(String msg) {
		LOGGER.error(msg);
		System.exit(1);
	}
	
	//Get style sheet depending on task
	private DBTransform getTransformer(String inputPath, String resultPath, String type) {
		//Use the inputPath's file name as the output's name
		File input = getFile(inputPath); 
		String resultName = input.getName().substring(0, input.getName().lastIndexOf(".")); 
		String result = resultPath + File.separator + resultName;
		switch (type.toLowerCase()) {
			case "tag":
				return new TagTransform(inputPath, tag_path, result + ".xml");
			case "pdf":
				return new PDFTransform(inputPath, pdf_path, result + ".pdf");
			case "html":
				return new HTMLTransform(inputPath, html_path, result + ".html");
			default: 
				exitPrint(type + " is not a supported type. Please choose tag, pdf, or html");
				return null;
		}
	}
}











