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
        <xsl:variable name="framePath">
            <xsl:value-of select="$frame"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <xsl:variable name="tableTag" select="."/>
        <!-- Create table headers -->
        <thead>
            <tr>
                <xsl:for-each select="./*[local-name() = 'column']">
                    <th>
                        <xsl:value-of select="."/>
                    </th>
                </xsl:for-each>
            </tr>
        </thead>
        <!-- Create table rows by calling other templates -->
        <xsl:for-each select="doc($framePath)//*[local-name() = 'result']">
            <!-- If the result matches up to any of the column names -->
            <xsl:if test="./*[@name = $tableTag/*[local-name() = 'column']]">
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
            <xsl:for-each select="$tableTag/*[local-name() = 'column']">
                <xsl:call-template name="rowHelper">
                    <xsl:with-param name="result" select="$result"/>
                    <xsl:with-param name="column" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <!--Helper function to fill in row data -->
    <xsl:template name="rowHelper">
        <xsl:param name="result"/>
        <xsl:param name="column"/>
        <td>
            <xsl:if test="$result/*[@name = $column]">
                <xsl:value-of select="normalize-space($result/*[@name = $column]/*)"/>
            </xsl:if>
        </td>
    </xsl:template>

</xsl:stylesheet>
