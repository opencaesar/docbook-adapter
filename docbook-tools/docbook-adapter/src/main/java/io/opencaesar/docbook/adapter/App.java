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
	private String inputPath;
	
	@Parameter(
		names = { "--type", "-t" },
		description = "Type of operation. Options are tag, pdf, or html (Required)",
		validateWith = TypeValidator.class,
		required = true,
		order = 2)
	private String type;
	
	@Parameter(
		names = { "--xsl", "-x" },
		description = "Path to the required XSL. (Required) Different for each type: \n" +
				"Tag: Path to the tag replacement XSL \n" +
				"PDF: Path to the extension PDF XSL (created in results/tag_gen when Tag is previously executed: fo_ext.xsl) \n" +
				"HTML: Path to the extension HTML XSL (created in results/tag_gen when Tag is previously executed: html_ext.xsl) \n" +
				"For original render for tag/html, give the path of the original DocBook XSL: \n" +
				"PDF: should be located in path/to/dockbook_xsl/fo/docbook.xsl \n" + 
				"HTML: should be located in path/to/dockbook_xsl/html/dockbook.xsl \n",
		required = true,
		order = 3)
	private String xslPath;
	
	@Parameter(
		names = { "--original", "-o" },
		description = "Path to the original DocBook XSLs (Required for tag replacement, otherwise optional)",
		required = false,
		order = 4)
	private String docPath = null;

	
	@Parameter(
		names = { "--frames", "-f" },
		description = "Path to the folder to save the result to (Required for tag replacement, otherwise optional)",
		required = false,
		order = 5)
	private String framePath = null;
	
	@Parameter(
		names = { "--save", "-s" },
		description = "Save the data. Will overwrite data in tag_gen/data (optional)",
		required = false,
		order = 6)
	public boolean save = false;

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
		//Create src-gen
		String srcParent = new File(inputPath).getParentFile().getParent();
		File srcGen = new File(srcParent + File.separator + "src-gen");
		if (!srcGen.exists()) {
			//Create src-gen if it doesn't exist, 
			if (!srcGen.mkdir()) {
				//Cannot create src-gen. Exit
				LOGGER.error("Cannot make src-gen. Exiting");
				System.exit(1);
			}
		}
		LOGGER.info("Results will be placed in: " + srcGen.getAbsolutePath());
		//Get DBTransformer class 
		DBTransformer trans = getTransformer(inputPath, srcGen.getPath(), type);
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
	private DBTransformer getTransformer(String inputPath, String resultDir, String type) {
		//Use the inputPath's file name as the output's name
		File input = new File(inputPath); 
		if (!input.exists()) {
			LOGGER.error("Input doesn't exist at: " + inputPath); 
			return null;
		}
		String result = resultDir + File.separator + input.getName().substring(0, input.getName().lastIndexOf("."));
		switch (type.toLowerCase()) {
			case "tag":
				return new TagTransform(inputPath, xslPath, result + ".xml", framePath, docPath, save);
			case "pdf":
				return new PDFTransform(inputPath, xslPath, result + ".pdf");
			case "html":
				return new HTMLTransform(inputPath, xslPath, result + ".html");
			default: 
				LOGGER.error(type + " is not a supported type. Please choose tag, pdf, or html");
				return null;
		}
	}
}
