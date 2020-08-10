<?xml version="1.0" encoding="UTF-8"?>
<!-- <getTable frame="query1.frame" title="Table" colList="component$mass"/> -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Given a frame and columns, genereate a table -->
    <xsl:template match="//*[local-name() = 'getTable']" name="createTable">
        <xsl:param name="frame" tunnel="yes"/>
        <!-- Title is optional; Use table for title and informalTable otherwise -->
        <xsl:choose>
            <xsl:when test="@title">
                <table border="1" class="getTable">
                    <caption>
                        <xsl:value-of select="@title"/>
                    </caption>
                    <xsl:call-template name="tableBody"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <informaltable border="1" class="getTable">
                    <xsl:call-template name="tableBody"/>
                </informaltable>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Table body -->
    <xsl:template name="tableBody">
        <xsl:param name="frame" tunnel="yes"/>
        <!-- Variable holding the entire tag. Used as we change nodes later -->
        <xsl:variable name="tableTag" select="."/>
        <xsl:variable name="framePath">
            <!-- Frame variable is the frame path
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frame"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Create table headers -->
        <thead>
            <!-- If color is given; use it. Otherwise, use default green -->
            <xsl:variable name="pdfColor">
                <xsl:choose>
                    <xsl:when test="@headerColor">
                        <xsl:value-of select="@headerColor"/>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
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
            <tr style="{$htmlColor}">
                <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
                <xsl:call-template name="generateHeader">
                    <xsl:with-param name="tableTag" select="."/>
                </xsl:call-template>
            </tr>
        </thead>
        <!-- Create table rows by calling other templates -->
        <xsl:variable name="numCols" select="count($tableTag/*[local-name() = 'column'])"/>
        <tbody>
            <xsl:call-template name="generateRow">
                <xsl:with-param name="framePath" select="$framePath"/>
                <xsl:with-param name="tableTag" select="$tableTag"/>
            </xsl:call-template>
            <!-- Create nested tables or inline tables -->
            <xsl:for-each select="./*">
                <!-- Nested table -->
                <xsl:if test="local-name() = 'nestedTable'">
                    <tr>
                        <td colspan="{$numCols}">
                            <xsl:call-template name="createTable"/>
                        </td>
                    </tr>
                </xsl:if>
                <!-- Inline table -->
                <xsl:if test="local-name() = 'inlineTable'">
                    <xsl:call-template name="inlineTable">
                        <xsl:with-param name="frame" select="$frame"/>
                        <xsl:with-param name="numCols" select="$numCols"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </tbody>
    </xsl:template>
    
    <!-- Creates an inline table (which is essentially a bunch of tr elements) -->
    <xsl:template name="inlineTable">
        <xsl:param name="frame"/>
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
            <tr class="inlineHeader" style="{$htmlColor}">
                <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
                <td colspan="{$numCols}"><xsl:value-of select="@title"/></td>
            </tr>
        </xsl:if>
        <tr class="inlineHeader" style="{$htmlColor}">
            <!-- Use a processing instruction for the pdf format --> 
            <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
            <xsl:call-template name="generateHeader">
                <xsl:with-param name="tableTag" select="."/>
            </xsl:call-template>
        </tr>
        <xsl:variable name="inlinePath">
            <xsl:value-of select="$frame"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <xsl:call-template name="generateRow">
            <xsl:with-param name="tableTag" select="."/>
            <xsl:with-param name="framePath" select="$inlinePath"/>
        </xsl:call-template>
        <!-- Check for nested inlineTables -->
        <xsl:for-each select="./*[local-name() = 'inlineTable']">
            <xsl:call-template name="inlineTable">
                <xsl:with-param name="frame" select="$frame"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Creates th elements with the appropriate data for the headers 
         wrap these elements appropriately (such as with tr)-->
    <xsl:template name="generateHeader">
        <xsl:param name="tableTag"/>
        <xsl:for-each select="$tableTag/*[local-name() = 'column']">
            <!-- Create the header elements -->
            <th>
                <!-- (Choose @name if given, otherewise @target) -->
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@target"/>
                    </xsl:otherwise>
                </xsl:choose>
            </th>
        </xsl:for-each>
    </xsl:template>    

    <!-- Creates tr elements with the appropriate data for the table body 
         wrap these elements if needed (such as with tbody)-->
    <xsl:template name="generateRow">
        <xsl:param name="framePath"/>
        <xsl:param name="tableTag"/>
        <xsl:for-each select="document($framePath)//*[local-name() = 'result']">
            <!-- If the result has a binding that matches to any of the column's target att -->
            <xsl:variable name="result" select="."/>
            <xsl:if test="$result/*[@name = $tableTag/*[local-name() = 'column']/@target]">
                <tr>
                    <xsl:for-each select="$tableTag/*[local-name() = 'column']">
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
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
