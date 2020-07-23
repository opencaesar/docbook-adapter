<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- Templates that are shared between other XSLs --> 
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
 
    <!-- Helper function for making the header/footer rows -->
    <xsl:template name="header_footer_helper">
        <xsl:param name="position"/>
        <xsl:param name="filePath"/>
        <xsl:if test="document($filePath)//*[local-name() = $position]">
            <axsl:when test="$position = '{$position}'">
                <xsl:call-template name="h_f_content">
                    <xsl:with-param name="position" select="$position"/>
                    <xsl:with-param name="filePath" select="$filePath"/>
                </xsl:call-template>
                
            </axsl:when>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper function that creates the content for header/footer rows -->
    <xsl:template name="h_f_content">
        <xsl:param name="position"/>
        <xsl:param name="filePath"/>
        <xsl:for-each select="document($filePath)//*[local-name() = $position]/*[local-name() = 'child']">
            <fo:block>
                <xsl:value-of select="."/>
            </fo:block>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>