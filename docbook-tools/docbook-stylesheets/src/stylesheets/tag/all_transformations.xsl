<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output indent="yes"/>
    <!-- Params -->
    <xsl:param name="framePath"/>
    <xsl:param name="currDate"/>
    <xsl:param name="dataPath"/>

    <!-- Copy all the xml and apply the templates at the specified nodes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()">
                <xsl:with-param name="frameDir" select="$framePath" tunnel="yes"/>
                <xsl:with-param name="date" select="$currDate" tunnel="yes"/>
                <xsl:with-param name="data" select="$dataPath" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Include XSL style sheets for performing tag replacements -->
    <xsl:include href="headerAndFooter.xsl"/>
    <xsl:include href="common.xsl"/>
    <xsl:include href="getValue.xsl"/>
    <xsl:include href="getTable.xsl"/>
    <xsl:include href="signature.xsl"/>
    <xsl:include href="currentDate.xsl"/>
    <xsl:include href="titlePage.xsl"/>
    <xsl:include href="changeLog.xsl"/>
    <xsl:include href="mirrorSections.xsl"/>

</xsl:stylesheet>
