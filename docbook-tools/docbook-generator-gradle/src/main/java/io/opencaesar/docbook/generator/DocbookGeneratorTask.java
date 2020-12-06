package io.opencaesar.docbook.generator;

import java.util.ArrayList;

import org.gradle.api.DefaultTask;
import org.gradle.api.tasks.TaskAction;

public class DocbookGeneratorTask extends DefaultTask {
	// Args used in Docbook adapter
	public String input;
	public String output;
	public boolean debug;
	// Holds the args that will be passed to the main program 
	public final ArrayList<String> args = new ArrayList<String>(); 
	
	@TaskAction
	public void run() {
		addStringArg(input, "-i"); 
		addStringArg(output, "-o");
		if (debug) {
			args.add("-d");
		}
		DocbookGeneratorApp.main(args.toArray(new String[args.size()]));
	}
	
	// Adds the string arg and its name if the input isn't null
	private void addStringArg(String arg, String argName) {
		if (arg != null) {
			args.add(argName);
			args.add(arg); 
		}
	}
	
}