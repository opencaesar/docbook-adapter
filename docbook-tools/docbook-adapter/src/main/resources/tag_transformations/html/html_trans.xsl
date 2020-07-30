<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Params -->
    <xsl:param name="data_loc"/>
    <xsl:param name="original_loc"/>
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@*|node()">
        <xsl:copy >
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="data" select="$data_loc" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- Replace import original tag with the actual import statement: Required to work -->
    <xsl:template match="//*[local-name() = 'import_original']">
        <axsl:import href="{$original_loc}"/>
    </xsl:template>
    
    <!-- Import the necessary extensions here --> 
    <!--
    <xsl:include href="html_header_footer.xsl"/>
    <xsl:incldue href="html_title_format.xsl"/>
    -->
    
</xsl:stylesheet>