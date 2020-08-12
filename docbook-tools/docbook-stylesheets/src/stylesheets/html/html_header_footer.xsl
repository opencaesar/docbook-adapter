<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
    
    <!-- Create header -->
    <xsl:template match = "//*[local-name() = 'header']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of src-gen/data; append the file name -->
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
    
    <!-- Create footer --> 
    <xsl:template match = "//*[local-name() = 'footer']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Data has the location of src-gen/data; append the file name -->
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
        <!-- Template name written into the html_ext.xsl file.
             Template name is: user.{header/foot}.content-->
        <xsl:variable name="templateName">
            <xsl:text>user.</xsl:text><xsl:value-of select="$type"/><xsl:text>.content</xsl:text>
        </xsl:variable>
        <!-- Only create template if the file is available -->
        <xsl:if test="doc-available($filePath)">
            <axsl:template name="{$templateName}">
                <HR/>
                <table style="width: 100%">
                    <xsl:for-each select="document($filePath)//*[local-name() = 'child']">
                        <tr>
                            <!-- Left header content -->
                            <xsl:call-template name="generateContent">
                                <xsl:with-param name="position" select="'left'"/>
                            </xsl:call-template>
                            <!-- Center header content -->
                            <xsl:call-template name="generateContent">
                                <xsl:with-param name="position" select="'center'"/>
                            </xsl:call-template>
                            <!-- Right header content -->
                            <xsl:call-template name="generateContent">
                                <xsl:with-param name="position" select="'right'"/>
                            </xsl:call-template>
                        </tr>
                    </xsl:for-each>
                </table>
                <HR/>
            </axsl:template>
        </xsl:if>
    </xsl:template>
    
    <!-- Function that creates the content --> 
    <xsl:template name="generateContent">
        <xsl:param name="position"/>
        <td style="float:{$position}">
            <xsl:value-of select="./*[local-name() = $position]"/>
        </td>
    </xsl:template>
</xsl:stylesheet>













