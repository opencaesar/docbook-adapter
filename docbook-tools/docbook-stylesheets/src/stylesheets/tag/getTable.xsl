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
                <table border="1">
                    <caption>
                        <xsl:value-of select="@title"/>
                    </caption>
                    <xsl:call-template name="tableBody"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <informaltable border="1">
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
        <!-- Create table headers (Choose @name if given, otherewise @target) -->
        <thead>
            <tr>
                <xsl:for-each select="./*[local-name() = 'column']">
                    <th>
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
            </tr>
        </thead>
        <!-- Create table rows by calling other templates -->
        <xsl:for-each select="doc($framePath)//*[local-name() = 'result']">
            <!-- If the result has a binding that matches to any of the column's target att -->
            <xsl:if test="./*[@name = $tableTag/*[local-name() = 'column']/@target]">
                <xsl:call-template name="generateRow">
                    <xsl:with-param name="result" select="."/>
                    <xsl:with-param name="tableTag" select="$tableTag"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Generate rows -->
    <xsl:template name="generateRow">
        <xsl:param name="result"/>
        <xsl:param name="tableTag"/>
        <tr>
            <!-- Call the rowHelper for each column -->
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
    </xsl:template>
</xsl:stylesheet>
