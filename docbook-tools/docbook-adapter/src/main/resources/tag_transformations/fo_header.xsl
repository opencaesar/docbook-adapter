<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    <xsl:template match = "//*[local-name() = 'header']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of tag_gen/data; append the file name -->
        <!-- File name: header_info.xml -->
        <xsl:variable name="filePath">
            <xsl:value-of select="$data"/><xsl:text>header_info.xml</xsl:text>
        </xsl:variable>
        <xsl:if test="doc-available($filePath)">
            <axsl:template name="header.content">
                <axsl:param name="pageclass" select="''"/>
                <axsl:param name="sequence" select="''"/>
                <axsl:param name="position" select="''"/>
                <axsl:param name="gentext-key" select="''"/>
                <fo:block>
                    <axsl:choose>
                        <!-- If the header has set a left header, make the appropriate blocks -->
                        <xsl:call-template name="header_helper">
                            <xsl:with-param name="position" select="'left'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check right header -->
                        <xsl:call-template name="header_helper">
                            <xsl:with-param name="position" select="'right'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check center -->
                        <xsl:call-template name="header_helper">
                            <xsl:with-param name="position" select="'center'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                    </axsl:choose>
                </fo:block>
            </axsl:template>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper function for making the header -->
    <xsl:template name="header_helper">
        <xsl:param name="position"/>
        <xsl:param name="filePath"/>
        <xsl:if test="document($filePath)//*[local-name() = $position]">
            <axsl:when test="$position = '{$position}'">
                <xsl:for-each select="document($filePath)//*[local-name() = $position]/*[local-name() = 'child']">
                    <fo:block>
                        <xsl:message><xsl:value-of select="."/></xsl:message>
                        <xsl:value-of select="."/>
                    </fo:block>
                </xsl:for-each>
            </axsl:when>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>













