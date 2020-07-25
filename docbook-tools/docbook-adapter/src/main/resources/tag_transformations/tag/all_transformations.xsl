<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <!-- Global Param holding the file path of the query folder -->
    <xsl:param name="framePath"/>
    <xsl:param name="foPath"/>
    <xsl:param name="htmlPath"/>
    <xsl:param name="currDate"/>
    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@*|node()">
        <xsl:copy >
            <xsl:apply-templates select="@*|node()">
            	<xsl:with-param name="frame" select="$framePath" tunnel="yes"/>
                <xsl:with-param name="date" select="$currDate" tunnel="yes"/>
                <!--
                <xsl:with-param name="fo" select="$foPath" tunnel="yes"/>
                <xsl:with-param name="html" select="$htmlPath" tunnel="yes"/>
                -->
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Include XSLT style sheets for performing tag replacements -->
    <xsl:include href="getValue.xsl"/>
    <xsl:include href="getTable.xsl"/>
    <xsl:include href="createHeader.xsl"/>
    <xsl:include href="createFooter.xsl"/>
    <xsl:include href="signature.xsl"/>
    <xsl:include href="date.xsl"/>

</xsl:stylesheet>