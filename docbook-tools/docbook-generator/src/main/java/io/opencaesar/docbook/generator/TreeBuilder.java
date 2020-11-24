package io.opencaesar.docbook.generator;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.commons.io.IOUtils;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.RDFNode;
import org.apache.jena.rdfconnection.RDFConnection;
import org.apache.jena.rdfconnection.RDFConnectionFactory;
import org.apache.log4j.Logger;

public class TreeBuilder {
	
	private static final Logger LOG = Logger.getLogger(TreeBuilder.class);
	
	public class Node {
		private String iri;
		private Map<String, RDFNode> bindings = new HashMap<>();
		private List<Node> children = new ArrayList<>();
		private Set<String> types;
		
		private Node(String iri) {
			this.iri = iri;
			types = elementTypes.getOrDefault(iri, Collections.emptySet()).stream().map(Object::toString).collect(Collectors.toSet());
			types.remove(DOC_PREFIX + "Element");
		}
		
		public String getIri() {
			return iri;
		}

		public Set<String> getTypes() {
			return types;
		}
		
		public Map<String, RDFNode> getBindings() {
			return bindings;
		}
		
		public List<Node> getChildren() {
			return children;
		}
		
		public String toString() {
			StringBuilder sb = new StringBuilder();
			toString(sb, "");
			return sb.toString();
		}
		
		private void toString(StringBuilder asString, String indent) {
			asString.append(indent).append("[").append(iri).append("]\n");
			asString.append(indent).append("  Types:");
			for (String type : types) {
				asString.append("\n").append(indent).append("    - ").append(type);
			}
			asString.append("\n").append(indent).append("  Bindings:");
			for (Map.Entry<String, RDFNode> binding : bindings.entrySet()) {
				asString.append("\n").append(indent).append("    ").append(binding.getKey()) .append(": ").append(binding.getValue().toString());
			}
			if (!children.isEmpty()) {
				asString.append("\n").append(indent).append("  Children:");
				String subIndent = indent + "    ";
				for (Node child : children) {
					asString.append("\n");
					child.toString(asString, subIndent + "  ");
				}
			}
		}
	}

	private static final String DOC_PREFIX = "http://opencaesar.io/document#";
	private static final String GET_VALUES_QUERY = getQuery("getValues.sparql");

	private Map<String, Map<String, RDFNode>> elementImpliedBindingValues = new HashMap<>();
	private Map<String, Set<RDFNode>> elementSparqlExpansions;
	private Map<String, Set<RDFNode>> elementSparqlMappings;
	private Map<String, Set<RDFNode>> elementChildren;
	private Map<String, Set<RDFNode>> elementRequiredBindings;
	private Map<String, Set<RDFNode>> elementOptionalBindings;
	private Map<String, Set<RDFNode>> elementForwardedBindings;
	private Map<String, Set<RDFNode>> elementTypes;
	
	private String documentIri;

	private TreeBuilder() {
		
	}
	
	public static Node buildTree(String sparqlEndpoint, String documentIri) {
		TreeBuilder tree = new TreeBuilder();
		tree.documentIri = documentIri;
		try (RDFConnection conn = RDFConnectionFactory.connect(sparqlEndpoint)) {
			tree.initImpliedBindings(conn);
			tree.elementSparqlExpansions = getValues(conn, DOC_PREFIX + "hasSparqlExpansion");
			tree.elementSparqlMappings = getValues(conn, DOC_PREFIX + "hasSparqlMapping");
			tree.elementChildren = getValues(conn, DOC_PREFIX + "hasElement");
			tree.elementRequiredBindings = getValues(conn, DOC_PREFIX + "hasRequiredBinding");
			tree.elementOptionalBindings = getValues(conn, DOC_PREFIX + "hasOptionalBinding");
			tree.elementForwardedBindings = getValues(conn, DOC_PREFIX + "hasForwardedBinding");
			
			tree.elementTypes = getMap(conn, getQuery("getElementTypes.sparql"), documentIri);
			tree.elementTypes.putAll(getMap(conn, getQuery("getDocumentType.sparql"), documentIri, documentIri));
			
			List<Node> nodes = tree.createNodes(conn, documentIri, Collections.emptyMap());
			
			if (!nodes.isEmpty()) {
				return nodes.get(0);
			} else {
				return null;
			}
		}
	}

	private List<Node> createNodes(RDFConnection conn, String elementIri, Map<String, RDFNode> forwardedBindings) {
		LOG.debug("Processing " + elementIri);
		Map<String, RDFNode> inputBindings = new HashMap<>(forwardedBindings);
		Map<String, Boolean> queryVars = new HashMap<>();
		List<Node> results;
		if (elementImpliedBindingValues.containsKey(elementIri)) {
			inputBindings.putAll(elementImpliedBindingValues.get(elementIri));
		}
		LOG.debug("Input Bindings: " + inputBindings.keySet());
		elementOptionalBindings.getOrDefault(elementIri, Collections.emptySet()).stream().map(o -> o.toString().split("\\s+")).forEach(splitName -> {
			if (splitName.length == 1) {
				queryVars.put(splitName[0], false);
			} else if (splitName.length == 3 && splitName[1].equalsIgnoreCase("as")) {
				queryVars.put(splitName[2], false);
				inputBindings.put(splitName[2], inputBindings.get(splitName[0]));
			} else {
				throw new IllegalStateException("Invalid @hasOptionalBinding format on " + elementIri);
			}
		});
		elementRequiredBindings.getOrDefault(elementIri, Collections.emptySet()).stream().map(o -> o.toString().trim().split("\\s+")).forEach(splitName -> {
			if (splitName.length == 1) {
				queryVars.put(splitName[0], true);
			} else if (splitName.length == 3 && splitName[1].equalsIgnoreCase("as")) {
				queryVars.put(splitName[2], true);
				inputBindings.put(splitName[2], inputBindings.get(splitName[0]));
			} else {
				throw new IllegalStateException("Invalid @hasRequiredBinding format on " + elementIri);
			}
		});
		if (elementSparqlExpansions.containsKey(elementIri)) {
			if (elementSparqlMappings.containsKey(elementIri)) {
				throw new IllegalStateException(elementIri + " has both expansion and mapping queries");
			}
			String query = createBindingQuery(elementIri, elementSparqlExpansions, inputBindings, queryVars);
			LOG.debug("Running Query: " + query);
			results = new ArrayList<>();
			try (QueryExecution exec = conn.query(query)) {
				exec.execSelect().forEachRemaining(solution -> {
					Node element = new Node(elementIri);
					for (Map.Entry<String, RDFNode> e : inputBindings.entrySet()) {
						element.bindings.put(e.getKey(), e.getValue());
					}
					solution.varNames().forEachRemaining(varName -> {
						element.bindings.put(varName, solution.get(varName));
					});
					results.add(element);
				});
			} catch (Exception e) {
				LOG.error("Failed in query: " + query, e);
				throw e;
			}
		} else {
			Node element = new Node(elementIri);
			element.iri = elementIri;
			for (Map.Entry<String, RDFNode> e : inputBindings.entrySet()) {
				element.bindings.put(e.getKey(), e.getValue());
			}
			if (elementSparqlMappings.containsKey(elementIri)) {
				String query = createBindingQuery(elementIri, elementSparqlMappings, inputBindings, queryVars);
				LOG.debug("Running Query: " + query);
				try (QueryExecution exec = conn.query(query)) {
					ResultSet resultSet = exec.execSelect();
					if (resultSet.hasNext()) {
						QuerySolution solution = resultSet.next();
						solution.varNames().forEachRemaining(varName -> {
							element.bindings.put(varName, solution.get(varName));
						});
					}
				} catch (Exception e) {
					LOG.error("Failed in query: " + query, e);
					throw e;
				}
			}
			results = Collections.singletonList(element);
		}
		for (Node result : results) {
			Map<String, RDFNode> forwardedToChildren = new HashMap<>();
			if (elementForwardedBindings.containsKey(elementIri)) {
				elementForwardedBindings.get(elementIri).stream().map(o -> o.toString().trim().split("\\s+")).forEach(bindingName -> {
					if (bindingName.length == 1) {
						if (bindingName[0].equals("*")) {
							forwardedToChildren.putAll(result.bindings);
						} else {
							forwardedToChildren.put(bindingName[0], result.bindings.get(bindingName[0]));
						}
					} else if (bindingName.length == 3 && bindingName[1].equalsIgnoreCase("as")) {
						forwardedToChildren.put(bindingName[2], result.bindings.get(bindingName[0]));
					} else {
						throw new IllegalStateException("Invalid @forwardedBinding format on " + elementIri);
					}
				});
			}
			elementChildren.getOrDefault(elementIri, Collections.emptySet()).stream().map(Object::toString).sorted().forEach(childIri -> {
				result.children.addAll(createNodes(conn, childIri, forwardedToChildren));
			});
		}
		return results;
	}
	
	private String createBindingQuery(String elementIri, Map<String, Set<RDFNode>> queryMap, Map<String, RDFNode> inputBindings, Map<String, Boolean> queryVars) {
		ParameterizedSparqlString sparql = new ParameterizedSparqlString(queryMap.get(elementIri).iterator().next().toString());
		
		for (Map.Entry<String, Boolean> queryVarAndRequired : queryVars.entrySet()) {
			String varName = queryVarAndRequired.getKey();
			RDFNode inputValue = inputBindings.get(varName);
			if (inputValue != null) {
				if (inputValue.isLiteral()) {
					sparql.setLiteral(varName, inputValue.asLiteral());
				} else if (inputValue.isResource()) {
					sparql.setIri(varName, inputValue.asResource().getURI());
				} else {
					throw new IllegalStateException("Unrecognized value type " + inputValue);
				}
			} else if ("DOCUMENT".equals(varName)) {
				sparql.setIri("DOCUMENT", documentIri);
			} else if ("SELF".equals(varName)) {
				sparql.setIri("SELF", elementIri);
			} else {
				if (queryVarAndRequired.getValue()) {
					throw new IllegalStateException("Required input binding " +  varName + " missing on " + elementIri);
				}
			}
		}
		return sparql.toString();
	}
	
    private static Map<String, Set<RDFNode>> getValues(RDFConnection conn, String property) {
        return getMap(conn, GET_VALUES_QUERY, property);
    }
    
    private static Map<String, Set<RDFNode>> getMap(RDFConnection conn, String query, String... parameterIris) {
    	Map<String, Set<RDFNode>> result = new HashMap<>();
    	ParameterizedSparqlString sparql = new ParameterizedSparqlString(query);
    	for (int i = 0; i < parameterIris.length; i++) {
    		sparql.setIri(i, parameterIris[i]);
    	}
        try (QueryExecution impliedBindings = conn.query(sparql.toString())) {
            impliedBindings.execSelect().forEachRemaining(solution -> {
                result.computeIfAbsent(solution.get("key").toString(), key -> new LinkedHashSet<>())
                        .add(solution.get("value"));
            });
        }
        return result;
    }

    private void initImpliedBindings(RDFConnection conn) {
        Map<String, Set<RDFNode>> propertyToImpliedBinding = getValues(conn, DOC_PREFIX + "impliesBinding");
        for (Map.Entry<String, Set<RDFNode>> propertyAndBindingNames : propertyToImpliedBinding.entrySet()) {
        	for (Map.Entry<String, Set<RDFNode>> subjectAndImpliedValues : getValues(conn, propertyAndBindingNames.getKey()).entrySet()) {
        		for (RDFNode bindingName : propertyAndBindingNames.getValue()) {
        			elementImpliedBindingValues.computeIfAbsent(subjectAndImpliedValues.getKey().toString(), key -> new HashMap<>())
                    	.put(bindingName.toString(), subjectAndImpliedValues.getValue().iterator().next());
        		}
        	}
        }
    }
    
    private static String getQuery(String fileName) {
        try (InputStream is = TreeBuilder.class.getClassLoader().getResourceAsStream("io/opencaesar/docbook/generator/" + fileName)) {
            return IOUtils.toString(is, StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new AssertionError(e);
        }
    }
}
