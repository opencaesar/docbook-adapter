<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <!-- Uses the function copyDataFile from common.xsl 
         common.xsl is not directly imported to avoid duplicate import statements
         common.xsl is instead imported at the all_transformation.xsl level -->

    <!-- Template for header tag. Creates a data file -->
    <xsl:template match="//*[local-name() = 'header']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Create a file in src-gen/data/header_info.xml" -->
        <xsl:call-template name="copyDataFile">
            <xsl:with-param name="data" select="$data" tunnel="yes"/>
            <xsl:with-param name="fileName" select="'header_info.xml'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template for footer tag. Creates a data file -->
    <xsl:template match="//*[local-name() = 'footer']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Create a file in src-gen/data/footer_info.xml" -->
        <xsl:call-template name="copyDataFile">
            <xsl:with-param name="data" select="$data" tunnel="yes"/>
            <xsl:with-param name="fileName" select="'footer_info.xml'"/>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
