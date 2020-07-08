package io.opencaesar.docbook.adapter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;


import org.apache.log4j.Appender;
import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.google.common.io.CharStreams;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.w3c.dom.Document;
import net.sf.saxon.BasicTransformerFactory;

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
		LOGGER.info("Result location: " + resultPath);
		//Variable holding the path to the master style sheet 
		final String stylePath = "xslt/all_transformations.xsl";
		File input = getFile(inputPath);
		
		//Open input file and the master xslt for tag replacement
		StreamSource docbook = new StreamSource(input);
		Transformer transformer = new net.sf.saxon.TransformerFactoryImpl()
				.newTransformer(new StreamSource (getFile(stylePath)));
		/*Transformer transformer = TransformerFactory.newInstance()
				.newTransformer(new StreamSource (getFile(stylePath)));*/
		
		//Create output file
		File res = new File(resultPath + "/" + input.getName());
		StreamResult output = new StreamResult(res);
		
		//Apply transformation
		transformer.transform(docbook, output);
		
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
		}
		return version;
	}
	
	//Check that file exists 
	private File getFile(String path) {
		File file = new File (path); 
		if (!file.exists()) {
			LOGGER.error("File does not exist at: " + path);
		}
		return file;
	}

}