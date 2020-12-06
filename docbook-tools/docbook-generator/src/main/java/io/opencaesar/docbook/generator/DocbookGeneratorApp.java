package io.opencaesar.docbook.generator;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ProcessingInstruction;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.io.CharStreams;

public class DocbookGeneratorApp {

	@Parameter(
		names = { "--input-path", "-i" },
		description = "SPARQL endpoint URL to query (Required)",
		required = true,
		order = 1)
	private String inputPath;

	@Parameter(
		names = { "--output-path", "-o" },
		description = "Output docbook filename (Required)",
		required = true,
		order = 3)
	private String outputPath;

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
		
		LOGGER.info("Input Filename:  " + inputPath);
		LOGGER.info("Output Filename: " + outputPath);
		
		BindingNode root = new ObjectMapper().readValue(new File(inputPath), BindingNode.class);
		
		File outputFile = new File(outputPath);
		if (!outputFile.getParentFile().exists()) {
			outputFile.getParentFile().mkdirs();
		}
		try (OutputStream output = new BufferedOutputStream(new FileOutputStream(outputFile))) {
			Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
			handle(document, root);
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
	        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
	        transformer.transform(new DOMSource(document), new StreamResult(output));
		}
		
	    LOGGER.info("=================================================================");
		LOGGER.info("                          E N D");
		LOGGER.info("=================================================================");
	}
	
	public static class BindingValue {
		private String type;
		private String value;
		private String datatype;
		@JsonProperty("xml:lang") private String lang;
		
		public String getType() {
			return type;
		}
		
		public String getValue() {
			return value;
		}
		
		public String getDatatype() {
			return datatype;
		}
		
		public String getLang() {
			return lang;
		}
	}

	public static class BindingNode {
		private String iri;
		private Set<String> types;
		private Map<String, BindingValue> bindings;
		private List<BindingNode> children;
		
		public String getIri() {
			return iri;
		}
		
		public Set<String> getTypes() {
			return types != null ? types : Collections.emptySet();
		}
		
		public Map<String, BindingValue> getBindings() {
			return bindings != null ? bindings : Collections.emptyMap();
		}
		
		public List<BindingNode> getChildren() {
			return children != null ? children : Collections.emptyList();
		}

		public String getString(String bindingName) {
			BindingValue value = getBindings().get(bindingName);
			return value != null ? value.value : null;
		}
	}
	
	private static final String DOC_PREFIX = "http://opencaesar.io/document#";
	private static final String DOCBOOK_NS = "http://docbook.org/ns/docbook";
	private static final String BINDING_ELEMENT_USER_DATA_KEY = DocbookGeneratorApp.class.getName() + ".BINDING_ELEMENT";
	
	private interface Handler {
		void handle(Node xmlParent, BindingNode treeNode);
	}
	private static final LinkedHashMap<String, Handler> handlers = new LinkedHashMap<String, Handler>();
	private static void addHandler(String type, Handler handler) {
		handlers.put(DOC_PREFIX + type, handler);
	}
	static {
		addHandler("Book", DocbookGeneratorApp::handleBook);
		addHandler("Preface", (p, n) -> handleTitled(p, n, "preface"));
		addHandler("Chapter", (p, n) -> handleTitled(p, n, "chapter"));
		addHandler("Section", (p, n) -> handleTitled(p, n, "section"));
		addHandler("Table", (p, n) -> handleTable("table", p, n));
		addHandler("InformalTable", (p, n) -> handleTable("informaltable", p, n));
		addHandler("TableRow", DocbookGeneratorApp::handleTableRow);
		addHandler("TableColumn", DocbookGeneratorApp::handleTableColumn);
		addHandler("Para", DocbookGeneratorApp::handlePara);
		addHandler("Block", (p, n) -> postProcess((Element)p, n));
		addHandler("TitlePage", DocbookGeneratorApp::handleTitlePage);
	}

	private static void handle(Node xmlParent, BindingNode treeNode) {
		for (Map.Entry<String, Handler> typeAndHandler : handlers.entrySet()) {
			if (treeNode.getTypes().contains(typeAndHandler.getKey())) {
				typeAndHandler.getValue().handle(xmlParent, treeNode);
				return;
			}
		}
		throw new IllegalStateException("No handler for " + treeNode.getIri());
	}
	
	private static void postProcess(Element xmlNode, BindingNode treeNode) {
		if (xmlNode.getUserData(BINDING_ELEMENT_USER_DATA_KEY) == null) {
			xmlNode.setUserData(BINDING_ELEMENT_USER_DATA_KEY, treeNode, null);
		}
		String hasId = treeNode.getString("hasId");
		if (hasId != null) {
			xmlNode.setAttribute("id", hasId);
		}
		String hasClass = treeNode.getString("hasClass");
		if (hasClass != null) {
			xmlNode.setAttribute("class", hasClass);
		}
		String hasStyle = treeNode.getString("hasStyle");
		if (hasStyle != null) {
			xmlNode.setAttribute("style", hasStyle);
		}
		String hasBackgroundColor = treeNode.getString("hasBackgroundColor");
		if (hasBackgroundColor != null) {
			ProcessingInstruction dbfo = xmlNode.getOwnerDocument().createProcessingInstruction("dbfo", "bgcolor=\"" + hasBackgroundColor + "\"");
			xmlNode.appendChild(dbfo);
		}
		for (BindingNode child : treeNode.getChildren()) {
			handle(xmlNode, child);
		}
	}
	
	private static Element addElement(Node parent, String name) {
		Element newElement = parent.getOwnerDocument().createElementNS(DOCBOOK_NS, name);
		parent.appendChild(newElement);
		return newElement;
	}
	
	private static void handleBook(Node xmlParent, BindingNode treeNode) {
		Element book = ((Document)xmlParent).createElementNS(DOCBOOK_NS, "book");
		xmlParent.appendChild(book);
		Element info = addElement(book, "info");
		String title = treeNode.getString("hasTitle");
		if (title != null) {
			addElement(info, "title").setTextContent(title);
		}
		postProcess(book, treeNode);
	}
	
	private static void handleTitled(Node xmlParent, BindingNode treeNode, String elementName) {
		Element domElement = addElement(xmlParent, elementName);
		String hasTitle = treeNode.getString("hasTitle");
		if (hasTitle != null) {
			addElement(domElement, "title").setTextContent(hasTitle);
		}
		postProcess(domElement, treeNode);
	}
	
	private static void handlePara(Node xmlParent, BindingNode element) {
		Element para = addElement(xmlParent, "para");
		addLinkableText(para, element);
		postProcess(para, element);
	}
	
	private static void addLinkableText(Element xmlParent, BindingNode element) {
		Element textNode = xmlParent;
		String hasLink = element.getString("hasLink");
		if (hasLink != null) {
			Element link = addElement(xmlParent, "link");
			link.setAttribute("linkend", hasLink.toString());
			textNode = link;
		}
		String hasText = element.getString("hasText");
		if (hasText != null) {
			textNode.setTextContent(hasText.toString());
		}
	}
	
	private static void handleTable(String tableElementName, Node xmlParent, BindingNode treeNode) {
		Element table = addElement(xmlParent, tableElementName);
		String hasTitle = treeNode.getString("hasTitle");
		if (hasTitle != null) {
			addElement(table, "caption").setTextContent(hasTitle);
		}
		String hasBorder = treeNode.getString("hasBorder");
		if (hasBorder != null) {
			table.setAttribute("border", hasBorder);
		}
		String hasBodyColor = treeNode.getString("hasBodyColor");
		if (hasBodyColor != null) {
			table.setAttribute("bodyColor", hasBodyColor);
		}
		postProcess(table, treeNode);
		if (table.getElementsByTagName("tbody").getLength() == 0) {
			xmlParent.removeChild(table);
		}
	}
	
	private static void handleTableRow(Node xmlParent, BindingNode treeNode) {
		NodeList tbodyElements = ((Element)xmlParent).getElementsByTagNameNS(DOCBOOK_NS, "tbody");
		Element tbody;
		if (tbodyElements.getLength() != 0) {
			tbody = (Element) tbodyElements.item(0);
		} else {
			Element thead = addElement(xmlParent, "thead");
			addElement(thead, "tr");
			tbody = addElement(xmlParent, "tbody");
		}
		Element tr = addElement(tbody, "tr");
		postProcess(tr, treeNode);
	}

	private static void handleTableColumn(Node xmlParent, BindingNode treeNode) {
		Element tbody = (Element)xmlParent.getParentNode();
		if (tbody.getElementsByTagNameNS(DOCBOOK_NS, "tr").getLength() == 1) {
			Element thead = (Element)((Element)tbody.getParentNode()).getElementsByTagNameNS(DOCBOOK_NS, "thead").item(0);
			Element headerRow = (Element)thead.getElementsByTagNameNS(DOCBOOK_NS, "tr").item(0);
			Element headerCell = addElement(headerRow, "td");
			String headerLabel = treeNode.getString("hasTitle");
			if (headerLabel != null) {
				headerCell.setTextContent(headerLabel);
			}
		}
		Element td = addElement(xmlParent, "td");
		addLinkableText(td, treeNode);
		postProcess(td, treeNode);
	}
	
	private static void handleTitlePage(Node xmlParent, BindingNode treeNode) {
		Element info = (Element) ((Element)xmlParent).getElementsByTagNameNS(DOCBOOK_NS, "info").item(0);
		Element rootList = addElement(info, "simplelist");
		List<BindingNode> preparers = treeNode.getChildren().stream().filter(child -> child.getTypes().contains(DOC_PREFIX + "Preparer")).collect(Collectors.toList());
		rootList.setAttribute("type", "vertical");
		rootList.setAttribute("columns", "1");
		if (!preparers.isEmpty()) {
			addElement(rootList, "member").setTextContent("Prepared by");
			addElement(rootList, "member").setTextContent("");
			addElement(rootList, "member").setTextContent("____________________________");
			for (BindingNode preparer : preparers) {
				Element preparerMember = addElement(rootList, "member");
				Element preparerList = addElement(preparerMember, "simplelist");
				preparerList.setAttribute("type", "inline");
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getString("hasName")));
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getString("hasRole")));
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getString("hasOrganization")));
			}
		}
		String hasDate = treeNode.getString("hasDate");
		if (hasDate != null) {
			info.appendChild(info.getOwnerDocument().createTextNode(hasDate));
		}
		String hasReleaseVersion = treeNode.getString("hasReleaseVersion");
		if (hasReleaseVersion != null) {
			addElement(info, "textobject").setTextContent(hasReleaseVersion);
		}
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
