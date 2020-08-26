<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oc="https://opencaesar.github.io/" exclude-result-prefixes="xs" version="2.0">
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
        <!-- Copy the attributes with vars replaced -->
        <xsl:for-each select="$target/@*[not(matches(name(.), $excludeList))]">
            <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
        </xsl:for-each>
    </xsl:template>


    <!-- Function to return filtering result --> 
    <xsl:function name="oc:checkFilter" as="xs:boolean">
        <xsl:param name="filterAttr"/>
        <xsl:param name="result"/>
        <!-- Get target and val by parsing filter string formatted as target = val -->
        <xsl:variable name="filter"><xsl:value-of select="$filterAttr"/></xsl:variable>
        <xsl:variable name="filterTarget" select="normalize-space(substring-before($filter, '='))"/>
        <xsl:variable name="filterVal" select="normalize-space(substring-after($filter, '='))"/>
        <xsl:variable name="resultVal">
            <xsl:value-of select="normalize-space($result/*[@name = $filterTarget]/*)"/>
        </xsl:variable>
        <xsl:message select="$resultVal = $filterVal"/>
        <xsl:value-of select="$resultVal = $filterVal"/>
    </xsl:function>
</xsl:stylesheet>
