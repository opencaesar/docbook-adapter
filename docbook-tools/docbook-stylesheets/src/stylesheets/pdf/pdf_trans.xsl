<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output indent="yes"/>
    <!-- Params -->
    <xsl:param name="dataPath"/>
    <xsl:param name="originalPath"/>
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@*|node()">
        <xsl:copy >
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="data" select="$dataPath" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- Replace import original tag with the actual import statement: Required to work -->
    <xsl:template match="//*[local-name() = 'import_original']">
        <axsl:import href="{$originalPath}"/>
    </xsl:template>
    
    <!-- Import the necessary extensions here --> 
    <xsl:include href="pdf_header_footer.xsl"/>
    <xsl:include href="pdf_title.xsl"/>
    
</xsl:stylesheet>