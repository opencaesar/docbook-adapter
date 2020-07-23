package io.opencaesar.docbook.adapter;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;

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
		//Get DBTransformer class 
		DBTransformer trans = getTransformer(inputPath, resultPath, type); 
		if (trans != null) {
			trans.apply();
		} else {
			LOGGER.error("Unable to apply transformation");
			System.exit(1);
		}
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
	
	//Get style sheet depending on task
	private DBTransformer getTransformer(String inputPath, String resultPath, String type) {
		//Use the inputPath's file name as the output's name
		File input = new File(inputPath); 
		if (!input.exists()) {
			LOGGER.error("Input doesn't exist at: " + inputPath); 
			return null;
		}
		String resultName = input.getName().substring(0, input.getName().lastIndexOf(".")); 
		String result = resultPath + File.separator + resultName;
		switch (type.toLowerCase()) {
			case "tag":
				return new TagTransform(inputPath, tag_path, result + ".xml", framePath, xslPath);
			case "pdf":
				return new PDFTransform(inputPath, pdf_path, result + ".pdf");
			case "html":
				return new HTMLTransform(inputPath, html_path, result + ".html");
			default: 
				LOGGER.error(type + " is not a supported type. Please choose tag, pdf, or html");
				return null;
		}
	}
}











