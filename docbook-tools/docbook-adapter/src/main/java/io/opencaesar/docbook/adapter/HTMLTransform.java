package io.opencaesar.docbook.adapter;

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
	
	public HTMLTransform (String inputPath, String stylePath, String resultPath) {
		super(inputPath, stylePath, resultPath);
	}

	@Override
	public void apply() {
		applyTransformation(getInput(), getStyle(), getResult()); 
	}
	
	@Override
	public void applyTransformation(File input, File style, File res) {
		try {
			Transformer transformer = new TransformerFactoryImpl()
					.newTransformer(new StreamSource(style));
			transformer.transform(new StreamSource(input), new StreamResult(res.toURI().getPath()));
		} catch (TransformerException e) {
			LOGGER.error("Cannot apply transformation. Printing stack trace: \n");
			e.printStackTrace();
			System.exit(1);
		}
	}
}