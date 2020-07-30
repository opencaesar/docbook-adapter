<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- Adds the necessary import statement to format a title page --> 
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
    <xsl:template match = "//*[local-name() = 'import_title']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of tag_gen/data; append the file name -->
        <!-- File name: title.xml -->
        <xsl:variable name="fileName">
            <xsl:text>title.xml</xsl:text>
        </xsl:variable>
        <xsl:variable name="filePath">
            <xsl:value-of select="$data"/><xsl:value-of select="$fileName"/>
        </xsl:variable>
        <!-- If the title.xml file is in tag_gen, import the title format xsl -->
        <!-- If the file isn't available, it will replace the tag in fo_base with nothing -->
        <xsl:if test="doc-available($filePath)">
            <axsl:include href="fo_title.xsl"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>