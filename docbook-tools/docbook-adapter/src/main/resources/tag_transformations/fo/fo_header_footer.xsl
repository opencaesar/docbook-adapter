<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    <!--Uses fo_common (include statement not written to avoid multiple inclusions-->
    
    <xsl:template match = "//*[local-name() = 'header']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of tag_gen/data; append the file name -->
        <!-- File name: header_info.xml -->
        <xsl:variable name="fileName">
            <xsl:text>header_info.xml</xsl:text>
        </xsl:variable>
        <xsl:call-template name="generateWrapper">
            <xsl:with-param name="data" tunnel="yes" select="$data"/>
            <xsl:with-param name="type" select="'header'"/>
            <xsl:with-param name="fileName" select="$fileName"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match = "//*[local-name() = 'footer']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of tag_gen/data; append the file name -->
        <!-- File name: footer_info.xml -->
        <xsl:variable name="fileName">
            <xsl:text>footer_info.xml</xsl:text>
        </xsl:variable>
        <xsl:call-template name="generateWrapper">
            <xsl:with-param name="data" tunnel="yes" select="$data"/>
            <xsl:with-param name="type" select="'footer'"/>
            <xsl:with-param name="fileName" select="$fileName"/>
        </xsl:call-template>
    </xsl:template>
        
    <!--Function that creates the wrapper for headers/footers-->
    <xsl:template name="generateWrapper">
        <xsl:param name="data" tunnel="yes"/>
        <xsl:param name="type"/>
        <xsl:param name="fileName"/>
        <xsl:variable name="filePath">
            <xsl:value-of select="$data"/><xsl:value-of select="$fileName"/>
        </xsl:variable>
        <xsl:variable name="contentType">
            <xsl:value-of select="$type"/><xsl:text>.content</xsl:text>
        </xsl:variable>
        <xsl:if test="doc-available($filePath)">
            <axsl:template name="{$contentType}">
                <axsl:param name="pageclass" select="''"/>
                <axsl:param name="sequence" select="''"/>
                <axsl:param name="position" select="''"/>
                <axsl:param name="gentext-key" select="''"/>
                <fo:block>
                    <axsl:choose>
                        <!-- If the header has set a left header, make the appropriate blocks -->
                        <xsl:call-template name="generateContent">
                            <xsl:with-param name="position" select="'left'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check center -->
                        <xsl:call-template name="generateContent">
                            <xsl:with-param name="position" select="'center'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check right -->
                        <axsl:when test="$position = 'right'">
                            <xsl:call-template name="contentHelper">
                                <xsl:with-param name="position" select="'right'"/>
                                <xsl:with-param name="filePath" select="$filePath"/>
                            </xsl:call-template>
                            <xsl:if test="$type = 'footer'">
                                <fo:block>
                                    <fo:page-number/>
                                </fo:block>
                            </xsl:if>
                        </axsl:when>
                    </axsl:choose>
                </fo:block>
            </axsl:template>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper function for making the header/footer rows -->
    <xsl:template name="generateContent">
        <xsl:param name="position"/>
        <xsl:param name="filePath"/>
        <xsl:if test="document($filePath)//*[local-name() = $position]">
            <axsl:when test="$position = '{$position}'">
                <xsl:call-template name="contentHelper">
                    <xsl:with-param name="position" select="$position"/>
                    <xsl:with-param name="filePath" select="$filePath"/>
                </xsl:call-template>
            </axsl:when>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper function that creates the content for header/footer rows -->
    <xsl:template name="contentHelper">
        <xsl:param name="position"/>
        <xsl:param name="filePath"/>
        <xsl:for-each select="document($filePath)//*[local-name() = $position]/*[local-name() = 'child']">
            <fo:block>
                <xsl:value-of select="."/>
            </fo:block>
        </xsl:for-each>
    </xsl:template>

    
    
</xsl:stylesheet>