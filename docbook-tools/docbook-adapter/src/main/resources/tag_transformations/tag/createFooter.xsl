<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Extend the fo extension file to add headers -->
    <xsl:template match="//*[local-name() = 'createFooter']">
        <xsl:result-document href="./tag_gen/data/footer_info.xml" >
            <xsl:copy-of select="."/>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>