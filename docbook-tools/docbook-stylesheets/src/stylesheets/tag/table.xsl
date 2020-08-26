<?xml version="1.0" encoding="UTF-8"?>
<!-- <getTable frame="query1.frame" title="Table" colList="component$mass"/> -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    xmlns:oc="https://opencaesar.github.io/"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Given a frame and columns, genereate a table -->
    <xsl:template match="oc:table" name="createTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <!-- Title is optional; Use table for title and informalTable otherwise -->
        <xsl:choose>
            <xsl:when test="@title">
                <table class="getTable" border="0">
                    <!-- Inherit attributes to table --> 
                    <xsl:call-template name="inheritAttributes">
                        <xsl:with-param name="excludeList" select="'filter|title|frame'"/>
                        <xsl:with-param name="target" select="."/>
                    </xsl:call-template>
                    <caption>
                        <xsl:value-of select="@title"/>
                    </caption>
                    <xsl:call-template name="tableBody"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <informaltable class="getTable" border="0">
                    <!-- Inherit attributes to table --> 
                    <xsl:call-template name="inheritAttributes">
                        <xsl:with-param name="excludeList" select="'filter|title|frame'"/>
                        <xsl:with-param name="target" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="tableBody"/>
                </informaltable>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Table body -->
    <xsl:template name="tableBody">
        <xsl:param name="frameDir" tunnel="yes"/>
        <!-- Variable holding the entire tag. Used as we change nodes later -->
        <xsl:variable name="tableTag" select="."/>
        <xsl:variable name="framePath">
            <!-- Frame variable is the frame path
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Create table headers -->
        <thead>
            <xsl:call-template name="generateHeader">
                <xsl:with-param name="class" select="'getTableHeader'"/>
                <xsl:with-param name="altColor" select="''"/>
            </xsl:call-template>
        </thead>
        <!-- Create table rows by calling other templates -->
        <xsl:variable name="numCols" select="count($tableTag/oc:column)"/>
        <tbody>
            <!-- Always add an empty row to avoid empty table error -->
            <tr>
                <td colspan="{$numCols}"/>
            </tr>
            <!-- Check for additional headers --> 
            <xsl:for-each select="./oc:tableHeader">
                <xsl:call-template name="generateHeader">
                    <xsl:with-param name="class" select="'addHeader'"/>
                    <xsl:with-param name="altColor" select="'#80bfff'"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:call-template name="generateRow">
                <xsl:with-param name="framePath" select="$framePath"/>
                <xsl:with-param name="tableTag" select="$tableTag"/>
            </xsl:call-template>
            <!-- Create nested tables or inline tables --> 
            <xsl:apply-templates select="./*[local-name() = 'nestedTable' or local-name() = 'inlineTable']">
                <xsl:with-param name="frameDir" select="$frameDir" tunnel="yes"/>
                <xsl:with-param name="numCols" select="$numCols"/>
            </xsl:apply-templates>
        </tbody>
    </xsl:template>
    
    <!-- Creates a nested table by making a tr that spans all columns of the original table -->
    <xsl:template name="nestedTable" match="oc:nestedTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:param name="numCols"/>
        <tr>
            <td colspan="{$numCols}">
                <xsl:call-template name="createTable">
                    <xsl:with-param name="frameDir" select="$frameDir" tunnel="yes"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    
    <!-- Creates an inline table (which is essentially a bunch of tr elements) -->
    <xsl:template name="inlineTable" match="oc:inlineTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:param name="numCols"/>
        <!-- If color is given; use it. Otherwise, use default green -->
        <xsl:variable name="pdfColor">
            <xsl:choose>
                <xsl:when test="@headerColor">
                    <xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise>#BFDFBF</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- If color is given; use it. Otherwise, default to the css --> 
        <xsl:variable name="htmlColor">
            <xsl:choose>
                <xsl:when test="@headerColor">background-color:<xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Create title if given -->
        <xsl:if test="@title">
            <tr class="inlineTitle" style="{$htmlColor}">
                <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
                <th colspan="{$numCols}">
                    <emphasis role="bold"><xsl:value-of select="@title"/></emphasis>
                </th>
            </tr>
        </xsl:if>
        <xsl:call-template name="generateHeader">
            <xsl:with-param name="class" select="'inlineHeader'"/>
            <xsl:with-param name="altColor" select="'#BFDFBF'"/>
        </xsl:call-template>
        <xsl:variable name="inlinePath">
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <xsl:call-template name="generateRow">
            <xsl:with-param name="tableTag" select="."/>
            <xsl:with-param name="framePath" select="$inlinePath"/>
        </xsl:call-template>
        <!-- Create nested tables or inline tables --> 
        <xsl:apply-templates select="./*[local-name() = 'nestedTable' or local-name() = 'inlineTable']">
            <xsl:with-param name="frame" select="$frameDir" tunnel="yes"/>
            <xsl:with-param name="numCols" select="$numCols"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Creates th elements with the appropriate data for the headers and
         wraps these elements appropriately-->
    <xsl:template name="generateHeader">
        <xsl:param name="class"/>
        <xsl:param name="altColor"/>
        <!-- If color is given; use it. Otherwise, use the given altColor -->
        <xsl:variable name="pdfColor">
            <xsl:choose>
                <xsl:when test="@headerColor">
                    <xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$altColor"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- If color is given; use it. Otherwise, default to the css --> 
        <xsl:variable name="htmlColor">
            <xsl:choose>
                <xsl:when test="@headerColor">background-color:<xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Apply the style to the tr -->
        <tr class="{$class}" style="{$htmlColor}">
            <!-- Use a processing instruction for the pdf format --> 
            <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
            <xsl:for-each select="./oc:column">
                <!-- Create the header elements -->
                <th>
                    <!-- Wrap in emphasis to create bold text --> 
                    <emphasis role="bold">
                        <!-- (Choose @name if given, otherewise @target) -->
                        <xsl:choose>
                            <xsl:when test="@name">
                                <xsl:value-of select="@name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@target"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </emphasis>
                </th>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <!-- Creates tr elements with the appropriate data for the table body 
         wrap these elements if needed (such as with tbody)-->
    <xsl:template name="generateRow">
        <xsl:param name="framePath"/>
        <xsl:param name="tableTag"/>
        <!-- Organize rows based on the first column's value -->
        <xsl:for-each select="document($framePath)/*/*/*[local-name() = 'result']">
            <xsl:variable name="result" select="."/>
            <!-- If the result has a binding that matches to any of the column's target att -->
            <xsl:if test="$result/*[@name = $tableTag/oc:column/@target]">
                <!-- Check for a filter -->
                <xsl:choose>
                    <xsl:when test="$tableTag/@filter">
                        <!-- Function located in common.xsl -->
                        <xsl:if test="oc:checkFilter($tableTag/@filter, $result)">
                            <xsl:call-template name="generateData">
                                <xsl:with-param name="result" select="$result"/>
                                <xsl:with-param name="tableTag" select="$tableTag"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- No filter, so generate data -->
                        <xsl:call-template name="generateData">
                            <xsl:with-param name="result" select="$result"/>
                            <xsl:with-param name="tableTag" select="$tableTag"/>
                        </xsl:call-template>                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Create a table row based on the data from the SPARQL result -->
    <xsl:template name="generateData">
        <xsl:param name="tableTag"/>
        <xsl:param name="result"/>
        <tr>
            <xsl:for-each select="$tableTag/oc:column">
                <xsl:variable name="target">
                    <xsl:value-of select="@target"/>
                </xsl:variable>
                <td>
                    <xsl:if test="$result/*[@name = $target]">
                        <xsl:value-of select="normalize-space($result/*[@name = $target]/*)"/>
                    </xsl:if>
                </td>
            </xsl:for-each>
        </tr>
    </xsl:template>
</xsl:stylesheet>
