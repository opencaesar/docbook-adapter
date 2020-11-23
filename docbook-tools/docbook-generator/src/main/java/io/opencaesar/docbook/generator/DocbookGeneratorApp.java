package io.opencaesar.docbook.generator;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.google.common.io.CharStreams;

public class DocbookGeneratorApp {

	@Parameter(
		names = { "--endpoint", "-e" },
		description = "SPARQL endpoint URL to query (Required)",
		required = true,
		order = 1)
	private String sparqlEndpoint;

	@Parameter(
		names = { "--iri", "-i" },
		description = "Document IRI to generate (Required)",
		required = true,
		order = 2)
	private String documentIri;

	@Parameter(
		names = { "--output", "-o" },
		description = "Output docbook filename (Required)",
		required = true,
		order = 3)
	private String outputFilename;

	@Parameter(
		names = { "-d", "--debug" },
		description = "Shows debug logging statements",
		order = 4)
	private boolean debug;

	@Parameter(
		names = { "--help", "-h" },
		description = "Displays summary of options",
		help = true,
		order = 5)
	private boolean help;

	private final Logger LOGGER = LogManager.getLogger(DocbookGeneratorApp.class); {
        DOMConfigurator.configure(ClassLoader.getSystemClassLoader().getResource("log4j.xml"));
	}
	
	public static void main(String[] args) {
		final DocbookGeneratorApp app = new DocbookGeneratorApp();
		final JCommander builder = JCommander.newBuilder().addObject(app).build();
		builder.parse(args);
		if (app.help) {
			builder.usage();
			return;
		}
		if (app.debug) {
			LogManager.getRootLogger().setLevel(Level.DEBUG);
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
		LOGGER.info("               DocBook Generator " + getAppVersion());
		LOGGER.info("=================================================================");
		
		LOGGER.info("SPARQL Endpoint: " + sparqlEndpoint);
		LOGGER.info("Document IRI: " + documentIri);
		LOGGER.info("Output Filename: " + outputFilename);
		
		TreeBuilder.Node root = TreeBuilder.buildTree(sparqlEndpoint, documentIri);
				
		if (LOGGER.isDebugEnabled()) {
			LOGGER.debug("Tree: " + root);
		}
		
		try (OutputStream output = new BufferedOutputStream(new FileOutputStream(outputFilename))) {
			DocbookWriter.writeAsDocbook(root, output);
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
}
