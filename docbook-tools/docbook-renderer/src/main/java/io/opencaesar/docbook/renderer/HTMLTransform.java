package io.opencaesar.docbook.renderer;

import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.xalan.processor.TransformerFactoryImpl;

/**
 * Class that implements DBTransform.
 * Used for HTML. Applies the appropriate XSL to get HTML format
 */
public class HTMLTransform extends DBTransformer {
	String css;
	
	public HTMLTransform (String inputPath, String stylePath, String resultPath, String cssPath) {
		super(inputPath, stylePath, resultPath);
		css = cssPath;
	}

	@Override
	public void apply() {
		applyTransformation(getInput(), getStyle(), getResult()); 
	}
	
	//Uses the xalan XSLT processor (rather than Saxon 9.9 he) to support the DocBook 1.0 XSL 
	//DocBook 1.0 XSL uses a legacy feature that prevents Saxon 9.9 from executing the XSLT
	@Override
	public void applyTransformation(File input, File style, File res) {
		try {
			Transformer transformer = new TransformerFactoryImpl()
					.newTransformer(new StreamSource(style));
			// Get absolute path due to relative pathing issues
			// If file doesn't exist, don't use a style sheet
			String cssPath = ""; 
			File cssFile = new File(css); 
			if (cssFile.exists()) {
				cssPath = cssFile.getAbsolutePath();
				transformer.setParameter("html.stylesheet", cssPath);
			} else {
				LOGGER.info("CSS File was not found at: " + css);
				LOGGER.info("No CSS will be used");
			}
			// transformer.setParameter("section.autolabel", "1");
			// transformer.setParameter("chapter.autolabel", "0");
			addCommonParams(transformer);
			transformer.transform(new StreamSource(input), new StreamResult(res.toURI().getPath()));
		} catch (TransformerException e) {
			LOGGER.error("Cannot apply transformation. Printing stack trace: \n");
			e.printStackTrace();
			System.exit(1);
		}
	}
}