<?xml version="1.0" encoding="UTF-8"?>
<!-- <getTable frame="query1.frame" title="Table" colList="component$mass"/> -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns='http://docbook.org/ns/docbook'
    xmlns:oc="https://github.com/opencaesar/docbook-tools"
    exclude-result-prefixes="xs oc"
    version="2.0">
    <!-- Given a frame and columns, genereate a table -->
    <xsl:template match="//*[local-name() = 'getTable']">
        <xsl:param name="file" tunnel="yes"/>
        <!-- Title is optional; Use table for title and informalTable otherwise -->
        <xsl:choose>
            <xsl:when test=".[@title]">
                <table>
                    <caption><xsl:value-of select="@title"/></caption>
                    <xsl:call-template name="tableBody"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <informaltable>
                    <xsl:call-template name="tableBody"/>
                </informaltable>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Table body -->    
    <xsl:template name="tableBody">
        <xsl:param name="file" tunnel="yes"/>
        <xsl:variable name="filePath"> 
            <xsl:value-of select="$file"/><xsl:value-of select="@frame"/>
        </xsl:variable>
        <xsl:variable name="colList"><xsl:value-of select="@colList"/></xsl:variable>
        <!-- Token is optional; use user input if given, otherwise use $ as default separateor -->
        <xsl:variable name="token">
            <xsl:choose>
                <xsl:when test=".[@token]">
                    <xsl:value-of select="@token" disable-output-escaping="yes"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text disable-output-escaping="yes">\$</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Create table headers -->
        <thead>
            <tr>
                <xsl:for-each select="tokenize($colList,$token)">
                    <th><xsl:value-of select="."/></th>
                </xsl:for-each>
            </tr>
        </thead>
        <!-- Create table rows by calling other templates -->
        <xsl:for-each select="doc($filePath)//*[local-name() = 'result']">
            <xsl:if test="./*[@name = tokenize($colList, $token)]">
                <xsl:call-template name="generateRow">
                    <xsl:with-param name="result" select="."/>
                    <xsl:with-param name="colList" select="$colList"/>
                    <xsl:with-param name="token" select="$token"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Generate rows -->
    <xsl:template name="generateRow">
        <xsl:param name="result"/>
        <xsl:param name="colList"/>
        <xsl:param name="token"/>
        <tr>
            <xsl:for-each select="tokenize($colList, $token)">
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
