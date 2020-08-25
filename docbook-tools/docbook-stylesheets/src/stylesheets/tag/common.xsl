<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <!-- Named templates that are common to multiple XSLs used in tag replacement -->

    <!-- Used to copy an element to a file in src-gen/data/{fileName} -->
    <xsl:template name="copyDataFile">
        <xsl:param name="data" tunnel="yes"/>
        <xsl:param name="fileName"/>
        <xsl:variable name="filePath">
            <xsl:value-of select="$data"/>
            <xsl:value-of select="$fileName"/>
        </xsl:variable>
        <xsl:result-document href="{$filePath}">
            <xsl:copy-of select="."/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- Used to copy attributes that are not specific to the tag --> 
    <!-- Allows users to add DocBook attributes to the underlying tags -->
    <!-- Exclude list is expected to be formatted as: name1|name2|... -->
    <xsl:template name="inheritAttributes">
        <xsl:param name="excludeList"/>
        <xsl:param name="target"/>
        <xsl:message>s</xsl:message>
        <xsl:message select="$target">Target</xsl:message>
        <xsl:message select="@*"/>
        <!-- Copy the attributes with vars replaced -->
        <xsl:for-each select="$target/@*[not(matches(name(), $excludeList))]">
            <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
            <xsl:message>En</xsl:message>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
