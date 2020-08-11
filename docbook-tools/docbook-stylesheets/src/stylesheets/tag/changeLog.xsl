<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns='http://docbook.org/ns/docbook'
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Variables holding the namespaces used in the issues vocab
             User with conncat to label specific things in the vocab --> 
    <xsl:variable name="issueNS" as="xs:string">
        <xsl:text>http://imce.jpl.nasa.gov/foundation/issue/issue#</xsl:text>
    </xsl:variable>
    <xsl:variable name="rdfSchemaNS" as="xs:string">
        <xsl:text>http://www.w3.org/2000/01/rdf-schema#</xsl:text>
    </xsl:variable>
    
    <!-- Create an article with a change log -->
    <xsl:template match="//*[local-name() = 'changeLog']">
        <xsl:param name="frame" tunnel="yes"/>
        <xsl:variable name="framePath"> 
            <xsl:value-of select="$frame"/><xsl:value-of select="@frame"/>
        </xsl:variable>
        <article> 
            <title>Change Log</title>
            <!-- Start table creation -->
            <xsl:call-template name="changeTable">
                <xsl:with-param name="framePath" select="$framePath"/>
            </xsl:call-template>
        </article>
    </xsl:template>
    
    <!-- Create just the change log table to make it more extensible --> 
    <xsl:template name="changeTable" match="//*[local-name() = 'changeLogTable']">
        <xsl:param name="framePath"/>
        <!-- Test for the fields to be added --> 
        <xsl:variable name="includeDate" select="not(@hideDate = 'true')" as="xs:boolean"/>
        <xsl:variable name="includeCommit" select="@showCommitId = 'true'" as ="xs:boolean"/>
        <xsl:variable name="includeVersion" select="not(@hideVersion = 'true')" as="xs:boolean"/>
        <informaltable border="1" class="changeLog">
            <!-- Create table headers based on tag attributes --> 
            <thead>
                <tr>
                    <!-- Date -->
                    <xsl:if test="$includeDate">
                        <th>Date</th>
                    </xsl:if>
                    <!-- Commit message/ Change summary -->
                    <th>Change Summary</th>
                    <!-- Files edited --> 
                    <xsl:if test="$includeCommit">
                        <th>Commit Id</th>
                    </xsl:if>
                    <xsl:if test="$includeVersion">
                        <th>Tag Version</th>
                    </xsl:if>
                </tr>
            </thead>
            <tbody>
                <!-- For each commit, make a table row -->
                <xsl:for-each select="distinct-values(document($framePath)/*/*/*[local-name() = 'result']/*[1]/*[1])">
                    <!-- Go up to the result node level to get commit ID associated with the label -->
                    <xsl:variable name="tagID" select="."/>
                    <tr>
                        <!-- Get the date data if date attribute is included --> 
                        <xsl:if test="$includeDate">
                            <xsl:call-template name="getData">
                                <xsl:with-param name="framePath" select="$framePath"/>
                                <xsl:with-param name="id" select="$tagID"/>
                                <xsl:with-param name="target" select="'tagDate'"/>
                            </xsl:call-template>
                        </xsl:if>
                        <!-- Get the commit message --> 
                        <xsl:call-template name="getData">
                            <xsl:with-param name="framePath" select="$framePath"/>
                            <xsl:with-param name="id" select="$tagID"/>
                            <xsl:with-param name="target" select="'tagMessage'"/>
                        </xsl:call-template>
                        <!-- Get the associated commit if chosen -->
                        <xsl:if test="$includeCommit">
                            <xsl:call-template name="getData">
                                <xsl:with-param name="framePath" select="$framePath"/>
                                <xsl:with-param name="id" select="$tagID"/>
                                <xsl:with-param name="target" select="'hasTaggedCommit'"/>
                            </xsl:call-template>
                        </xsl:if>
                        <!-- Get the tag version --> 
                        <xsl:if test="$includeVersion">
                            <xsl:call-template name="getData">
                                <xsl:with-param name="framePath" select="$framePath"/>
                                <xsl:with-param name="id" select="$tagID"/>
                                <xsl:with-param name="target" select="'tagVersion'"/>
                            </xsl:call-template>
                        </xsl:if>
                    </tr>
                </xsl:for-each>
            </tbody>
        </informaltable>
    </xsl:template>
    
    <!-- Given the target predicate (target) for a specific subject (commitID),
         create a td with the object in the s p o triple relation 
         Assumes the target is in the issues namespace -->
    <xsl:template name="getData">
        <xsl:param name="framePath"/> 
        <xsl:param name="id"/>
        <xsl:param name="target"/>
        <!-- First go from root to result (3 levels lower than root)-->
        <!-- Check if the result has a correct commit ID via descedant -->
        <!-- Check if the result has the target via descedant -->
        <!-- Return the object value by going to the last binding (object binding) and getting its value -->
        <td>
            <xsl:value-of select="data(document($framePath)/*/*/*
                [local-name() = 'result' and
                descendant::*[local-name() = 'uri' and . = $id] and 
                descendant::*[local-name() = 'uri' and . = concat($issueNS, $target)]]
                /*[last()]/*)" separator=", "/>
        </td>
    </xsl:template>
</xsl:stylesheet>