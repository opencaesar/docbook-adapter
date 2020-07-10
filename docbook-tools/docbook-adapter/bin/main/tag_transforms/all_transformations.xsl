<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@*|node()">
        <xsl:copy >
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Include XSLT style sheets for performing tag replacements -->
    <xsl:include href="getValue.xsl"/>
    <xsl:include href="getTable.xsl"/>
    
</xsl:stylesheet>