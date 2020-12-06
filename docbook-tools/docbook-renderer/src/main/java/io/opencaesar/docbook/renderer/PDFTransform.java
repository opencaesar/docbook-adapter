package io.opencaesar.docbook.renderer;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;

import net.sf.saxon.Configuration;
import net.sf.saxon.TransformerFactoryImpl;

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
		try {
			//Create an intermediate file for the XML-FO transformation 
			File temp; 
			temp = File.createTempFile("intermediate", ".xml", getResult().getParentFile());
			temp.deleteOnExit();
			//Apply XML -> XML-FO transformation
			applyTransformation(getInput(), getStyle(), temp);
			LOGGER.info("Now apply FOP to convert FO to PDF");
			//Apply XML-FO -> PDF transformation
			applyFOP(temp, getResult());
			// Delete the temp file again, as deleteOnExit isn't working when 
			// called through a gradle task
			temp.delete();
		} catch (IOException e) {
			LOGGER.error("File creation exception. Printing stack trace: \n ");
			e.printStackTrace();
			System.exit(1);
		}
		
	}
	
	//Applies the FOP transformation that transform a XML-FO into PDF
	private void applyFOP(File input, File result) {
		try {
			FopFactory fopFact = FopFactory.newInstance();
			//For the baseURL (which is used for things such as relative pathing for imgs) use the directory of the input docbook
			String baseURL = input.getParentFile().toURI().toURL().toString();
			fopFact.setBaseURL(baseURL);
			
			OutputStream out = new BufferedOutputStream(new FileOutputStream(result));
			Fop fop = fopFact.newFop(MimeConstants.MIME_PDF, out); 
			
			Configuration config = new Configuration(); 
			config.setXIncludeAware(true);
			Transformer transformer = new TransformerFactoryImpl(config)
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
}
