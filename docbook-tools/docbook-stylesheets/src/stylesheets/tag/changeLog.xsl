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
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:variable name="framePath"> 
            <xsl:value-of select="$frameDir"/><xsl:value-of select="@frame"/>
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
        <xsl:variable name="includeEditor" select="@showEditor = 'true'" as="xs:boolean"/>
        <!-- Create a getTable tag and pass it to the template -->
        
        <informaltable class="changeLog" frame="none">
            <!-- Create table headers based on tag attributes --> 
            <thead>
                <tr>
                    <!-- Date -->
                    <xsl:if test="$includeDate">
                        <th>Date</th>
                    </xsl:if>
                    <!-- Commit ID -->
                    <xsl:if test="$includeCommit">
                        <th>Commit Id</th>
                    </xsl:if>
                    <!-- Tag message/ Change summary -->
                    <th>Change Summary</th>
                    <!-- Editor / Person who made the tag -->
                    <xsl:if test="$includeEditor">
                        <th>Editor</th>
                    </xsl:if>
                    <!-- Version --> 
                    <xsl:if test="$includeVersion">
                        <th>Tag Version</th>
                    </xsl:if>
                </tr>
            </thead>
            <tbody>
                <!-- For each commit, make a table row -->
                <xsl:for-each select="document($framePath)/*/*/*[local-name() = 'result']">
                    <!-- Go up to the result node level to get commit ID associated with the label -->
                    <tr>
                        <!-- Get the date data if date attribute is included --> 
                        <xsl:call-template name="getData">
                            <xsl:with-param name="condition" select="$includeDate"/>
                            <xsl:with-param name="target" select="'date'"/>
                        </xsl:call-template>
                        <!-- Get the associated commit if chosen -->
                        <xsl:call-template name="getData">
                            <xsl:with-param name="condition" select="$includeCommit"/>
                            <xsl:with-param name="target" select="'commit'"/>
                        </xsl:call-template>
                        <!-- Get the commit message --> 
                        <xsl:call-template name="getData">
                            <xsl:with-param name="condition" select="true()"/>
                            <xsl:with-param name="target" select="'message'"/>
                        </xsl:call-template>
                        <!-- Get the person who created teh tag -->
                        <xsl:call-template name="getData">
                            <xsl:with-param name="condition" select="$includeEditor"/>
                            <xsl:with-param name="target" select="'editor'"/>
                        </xsl:call-template>
                        <!-- Get the tag version --> 
                        <xsl:call-template name="getData">
                            <xsl:with-param name="condition" select="$includeVersion"/>
                            <xsl:with-param name="target" select="'version'"/>
                        </xsl:call-template>
                    </tr>
                </xsl:for-each>
            </tbody>
        </informaltable>
    </xsl:template>
    
    <!-- If the condition is true, grab the target's value from the result -->
    <xsl:template name="getData">
        <xsl:param name="condition"/> 
        <xsl:param name="target"/>
        <xsl:if test="$condition">
            <td><xsl:value-of select="normalize-space(./*[@name = $target])"/></td>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>