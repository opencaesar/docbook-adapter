package io.opencaesar.docbook.adapter;

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