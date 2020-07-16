<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Global Param holding the file path of the query folder -->
    <xsl:param name="filePath"/>
    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@*|node()">
        <xsl:copy >
            <xsl:apply-templates select="@*|node()">
            	<xsl:with-param name="file" select="$filePath" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Include XSLT style sheets for performing tag replacements -->
    <xsl:include href="getValue.xsl"/>
    <xsl:include href="getTable.xsl"/>

</xsl:stylesheet>