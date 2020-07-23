<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
    <xsl:template match = "//*[local-name() = 'footer']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of tag_gen/data; append the file name -->
        <!-- File name: footer_info.xml -->
        <xsl:variable name="fileName">
            <xsl:text>footer_info.xml</xsl:text>
        </xsl:variable>
        <xsl:variable name="filePath">
            <xsl:value-of select="$data"/><xsl:value-of select="$fileName"/>
        </xsl:variable>
        <xsl:if test="doc-available($filePath)">
            <axsl:template name="footer.content">
                <axsl:param name="pageclass" select="''"/>
                <axsl:param name="sequence" select="''"/>
                <axsl:param name="position" select="''"/>
                <axsl:param name="gentext-key" select="''"/>
                <fo:block>
                    <axsl:choose>
                        <!-- If the header has set a left header, make the appropriate blocks -->
                        <xsl:call-template name="header_footer_helper">
                            <xsl:with-param name="position" select="'left'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check right header -->
                        <xsl:call-template name="header_footer_helper">
                            <xsl:with-param name="position" select="'right'"/>
                            <xsl:with-param name="filePath" select="$filePath"/>
                        </xsl:call-template>
                        <!-- Now check center -->
                        <axsl:when test="$position = 'center'">
                            <fo:block>
                                <fo:page-number/>
                            </fo:block>
                            <xsl:call-template name="h_f_content"/>
                        </axsl:when>
                    </axsl:choose>
                </fo:block>
            </axsl:template>
        </xsl:if>
    </xsl:template>
    
    
    
</xsl:stylesheet>