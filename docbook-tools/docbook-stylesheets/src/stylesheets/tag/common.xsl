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

</xsl:stylesheet>
