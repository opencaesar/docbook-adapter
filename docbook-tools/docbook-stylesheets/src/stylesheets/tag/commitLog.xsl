<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns='http://docbook.org/ns/docbook'
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Creates a change log based off of commits --> 
    <!-- Variables holding the namespaces used in the issues vocab
             User with conncat to label specific things in the vocab --> 
    <xsl:variable name="issueNS" as="xs:string">
        <xsl:text>http://imce.jpl.nasa.gov/foundation/issue/issue#</xsl:text>
    </xsl:variable>
    <xsl:variable name="rdfSchemaNS" as="xs:string">
        <xsl:text>http://www.w3.org/2000/01/rdf-schema#</xsl:text>
    </xsl:variable>
    
    <!-- Create an article with a change log -->
    <xsl:template match="//*[local-name() = 'changelog']">
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
        <xsl:variable name="includeDate" select="not(@hideDate = 'false')" as="xs:boolean"/>
        <xsl:variable name="includeFiles" select="@showEditedFiles = 'true'" as ="xs:boolean"/>
        <informaltable border="1">
            <!-- Create table headers based on tag attributes --> 
            <thead>
                <tr>
                    <!-- Date -->
                    <xsl:if test="$includeDate">
                        <td>Date</td>
                    </xsl:if>
                    <!-- Commit message/ Change summary -->
                    <td>Change Summary</td>
                    <!-- Files edited --> 
                    <xsl:if test="$includeFiles">
                        <td>Files Changed</td>
                    </xsl:if>
                </tr>
            </thead>
            <tbody>
                <!-- For each commit, make a table row -->
                <xsl:for-each select="distinct-values(document($framePath)/*/*/*[local-name() = 'result']/*[1]/*[1])">
                    <!-- Go up to the result node level to get commit ID associated with the label -->
                    <xsl:variable name="commitID" select="."/>
                    <tr>
                        <!-- Get the date data if date attribute is included --> 
                        <xsl:if test="$includeDate">
                            <xsl:call-template name="getCommitData">
                                <xsl:with-param name="framePath" select="$framePath"/>
                                <xsl:with-param name="commitID" select="$commitID"/>
                                <xsl:with-param name="target" select="'commitDate'"/>
                            </xsl:call-template>
                        </xsl:if>
                        <!-- Get the commit message --> 
                        <xsl:call-template name="getCommitData">
                            <xsl:with-param name="framePath" select="$framePath"/>
                            <xsl:with-param name="commitID" select="$commitID"/>
                            <xsl:with-param name="target" select="'commitMessage'"/>
                        </xsl:call-template>
                        <!-- Get the edited files if the showEditedFiles attribute is included -->
                        <xsl:if test="$includeFiles">
                            <xsl:call-template name="getCommitData">
                                <xsl:with-param name="framePath" select="$framePath"/>
                                <xsl:with-param name="commitID" select="$commitID"/>
                                <xsl:with-param name="target" select="'editsFile'"/>
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
    <xsl:template name="getCommitData">
        <xsl:param name="framePath"/> 
        <xsl:param name="commitID"/>
        <xsl:param name="target"/>
        <!-- First go from root to result (3 levels lower than root)-->
        <!-- Check if the result has a correct commit ID via descedant -->
        <!-- Check if the result has the target via descedant -->
        <!-- Return the object value by going to the last binding (object binding) and getting its value -->
        <td>
            <xsl:value-of select="data(document($framePath)/*/*/*
                [local-name() = 'result' and
                descendant::*[local-name() = 'uri' and . = $commitID] and 
                descendant::*[local-name() = 'uri' and . = concat($issueNS, $target)]]
                /*[last()]/*)" separator=", "/>
        </td>
    </xsl:template>
</xsl:stylesheet>