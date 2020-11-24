package io.opencaesar.docbook.generator;

import java.io.OutputStream;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.jena.rdf.model.RDFNode;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ProcessingInstruction;

public class DocbookWriter {
	
	private static final String DOC_PREFIX = "http://opencaesar.io/document#";
	private static final String DOCBOOK_NS = "http://docbook.org/ns/docbook";
	private static final String BINDING_ELEMENT_USER_DATA_KEY = DocbookWriter.class.getName() + ".BINDING_ELEMENT";
	
	private interface Handler {
		void handle(Node xmlParent, TreeBuilder.Node treeNode);
	}
	private static final LinkedHashMap<String, Handler> handlers = new LinkedHashMap<String, Handler>();
	private static void addHandler(String type, Handler handler) {
		handlers.put(DOC_PREFIX + type, handler);
	}
	static {
		addHandler("Book", DocbookWriter::handleBook);
		addHandler("Preface", (p, n) -> handleTitled(p, n, "preface"));
		addHandler("Chapter", (p, n) -> handleTitled(p, n, "chapter"));
		addHandler("Section", (p, n) -> handleTitled(p, n, "section"));
		addHandler("Table", (p, n) -> handleTable("table", p, n));
		addHandler("InformalTable", (p, n) -> handleTable("informaltable", p, n));
		addHandler("TableRow", DocbookWriter::handleTableRow);
		addHandler("TableColumn", DocbookWriter::handleTableColumn);
		addHandler("Para", DocbookWriter::handlePara);
		addHandler("Block", (p, n) -> postProcess((Element)p, n));
		addHandler("TitlePage", DocbookWriter::handleTitlePage);
	}
	
	public static void writeAsDocbook(TreeBuilder.Node node, OutputStream output) throws TransformerException {
		try {
			Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
			handle(document, node);
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
	        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
	        transformer.transform(new DOMSource(document), new StreamResult(output));
		} catch (ParserConfigurationException | TransformerFactoryConfigurationError e) {
			throw new IllegalStateException(e);
		}
	}
	

	private static void handle(Node xmlParent, TreeBuilder.Node treeNode) {
		for (Map.Entry<String, Handler> typeAndHandler : handlers.entrySet()) {
			if (treeNode.getTypes().contains(typeAndHandler.getKey())) {
				typeAndHandler.getValue().handle(xmlParent, treeNode);
				return;
			}
		}
		throw new IllegalStateException("No handler for " + treeNode.getIri());
	}
	
	private static void postProcess(Element xmlNode, TreeBuilder.Node treeNode) {
		if (xmlNode.getUserData(BINDING_ELEMENT_USER_DATA_KEY) == null) {
			xmlNode.setUserData(BINDING_ELEMENT_USER_DATA_KEY, treeNode, null);
		}
		RDFNode hasId = treeNode.getBindings().get("hasId");
		if (hasId != null) {
			xmlNode.setAttribute("id", hasId.toString());
		}
		RDFNode hasClass = treeNode.getBindings().get("hasClass");
		if (hasClass != null) {
			xmlNode.setAttribute("class", hasClass.toString());
		}
		RDFNode hasStyle = treeNode.getBindings().get("hasStyle");
		if (hasStyle != null) {
			xmlNode.setAttribute("style", hasStyle.toString());
		}
		RDFNode hasBackgroundColor = treeNode.getBindings().get("hasBackgroundColor");
		if (hasBackgroundColor != null) {
			ProcessingInstruction dbfo = xmlNode.getOwnerDocument().createProcessingInstruction("dbfo", "bgcolor=\"" + hasBackgroundColor + "\"");
			xmlNode.appendChild(dbfo);
		}
		for (TreeBuilder.Node child : treeNode.getChildren()) {
			handle(xmlNode, child);
		}
	}
	
	private static Element addElement(Node parent, String name) {
		Element newElement = parent.getOwnerDocument().createElementNS(DOCBOOK_NS, name);
		parent.appendChild(newElement);
		return newElement;
	}
	
	private static void handleBook(Node xmlParent, TreeBuilder.Node treeNode) {
		Element book = ((Document)xmlParent).createElementNS(DOCBOOK_NS, "book");
		xmlParent.appendChild(book);
		Element info = addElement(book, "info");
		RDFNode title = treeNode.getBindings().get("hasTitle");
		if (title != null) {
			addElement(info, "title").setTextContent(title.toString());
		}
		postProcess(book, treeNode);
	}
	
	private static void handleTitled(Node xmlParent, TreeBuilder.Node treeNode, String elementName) {
		Element domElement = addElement(xmlParent, elementName);
		RDFNode title = treeNode.getBindings().get("hasTitle");
		if (title != null) {
			addElement(domElement, "title").setTextContent(title.toString());
		}
		postProcess(domElement, treeNode);
	}
	
	private static void handlePara(Node xmlParent, TreeBuilder.Node element) {
		Element para = addElement(xmlParent, "para");
		addLinkableText(para, element);
		postProcess(para, element);
	}
	
	private static void addLinkableText(Element xmlParent, TreeBuilder.Node element) {
		Element textNode = xmlParent;
		RDFNode hasLink = element.getBindings().get("hasLink");
		if (hasLink != null) {
			Element link = addElement(xmlParent, "link");
			link.setAttribute("linkend", hasLink.toString());
			textNode = link;
		}
		RDFNode hasText = element.getBindings().get("hasText");
		if (hasText != null) {
			textNode.setTextContent(hasText.toString());
		}
	}
	
	private static void handleTable(String tableElementName, Node xmlParent, TreeBuilder.Node treeNode) {
		Element table = addElement(xmlParent, tableElementName);
		RDFNode hasTitle = treeNode.getBindings().get("hasTitle");
		if (hasTitle != null) {
			addElement(table, "caption").setTextContent(hasTitle.toString());
		}
		RDFNode hasBorder = treeNode.getBindings().get("hasBorder");
		if (hasBorder != null) {
			table.setAttribute("border", hasBorder.toString());
		}
		RDFNode hasBodyColor = treeNode.getBindings().get("hasBodyColor");
		if (hasBodyColor != null) {
			table.setAttribute("bodyColor", hasBodyColor.toString());
		}
		postProcess(table, treeNode);
		if (table.getElementsByTagName("tbody").getLength() == 0) {
			xmlParent.removeChild(table);
		}
	}
	
	private static void handleTableRow(Node xmlParent, TreeBuilder.Node treeNode) {
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

	private static void handleTableColumn(Node xmlParent, TreeBuilder.Node treeNode) {
		Element tbody = (Element)xmlParent.getParentNode();
		if (tbody.getElementsByTagNameNS(DOCBOOK_NS, "tr").getLength() == 1) {
			Element thead = (Element)((Element)tbody.getParentNode()).getElementsByTagNameNS(DOCBOOK_NS, "thead").item(0);
			Element headerRow = (Element)thead.getElementsByTagNameNS(DOCBOOK_NS, "tr").item(0);
			Element headerCell = addElement(headerRow, "td");
			RDFNode headerLabel = treeNode.getBindings().get("hasTitle");
			if (headerLabel != null) {
				headerCell.setTextContent(headerLabel.toString());
			}
		}
		Element td = addElement(xmlParent, "td");
		addLinkableText(td, treeNode);
		postProcess(td, treeNode);
	}
	
	private static void handleTitlePage(Node xmlParent, TreeBuilder.Node treeNode) {
		Element info = (Element) ((Element)xmlParent).getElementsByTagNameNS(DOCBOOK_NS, "info").item(0);
		Element rootList = addElement(info, "simplelist");
		List<TreeBuilder.Node> preparers = treeNode.getChildren().stream().filter(child -> child.getTypes().contains(DOC_PREFIX + "Preparer")).collect(Collectors.toList());
		rootList.setAttribute("type", "vertical");
		rootList.setAttribute("columns", "1");
		if (!preparers.isEmpty()) {
			addElement(rootList, "member").setTextContent("Prepared by");
			addElement(rootList, "member").setTextContent("");
			addElement(rootList, "member").setTextContent("____________________________");
			for (TreeBuilder.Node preparer : preparers) {
				Element preparerMember = addElement(rootList, "member");
				Element preparerList = addElement(preparerMember, "simplelist");
				preparerList.setAttribute("type", "inline");
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getBindings().get("hasName")));
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getBindings().get("hasRole")));
				addElement(preparerList, "member").setTextContent(String.valueOf(preparer.getBindings().get("hasOrganization")));
			}
		}
		RDFNode hasDate = treeNode.getBindings().get("hasDate");
		if (hasDate != null) {
			info.appendChild(info.getOwnerDocument().createTextNode(hasDate.toString()));
		}
		RDFNode hasReleaseVersion = treeNode.getBindings().get("hasReleaseVersion");
		if (hasReleaseVersion != null) {
			addElement(info, "textobject").setTextContent(hasReleaseVersion.toString());
		}
	}
}
