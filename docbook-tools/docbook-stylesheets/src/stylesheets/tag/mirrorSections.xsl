<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:template match="//*[local-name() = 'mirrorSection']" name="mirrorSection">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:variable name="frameFile">
            <!-- Frame param is the frame directory
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/><xsl:value-of select="@frame"/>
        </xsl:variable> 
        <xsl:variable name="sectionTag" select="."/>
        <xsl:variable name="varList" select="string-join(tokenize(@varList, ', '), '|')"/>
        <xsl:message select="$varList"/>
        <xsl:for-each select="document($frameFile)/*/*/*[local-name() = 'result']">
            <xsl:variable name="res" select="."/>
            <!-- Create a section with the title -->
            <section>
                <title>
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="$sectionTag/@title"/>
                        <xsl:with-param name="result" select="."/>
                        <xsl:with-param name="varList" select="$varList"/>
                    </xsl:call-template>
                </title>
                <!-- For each child, check for _vars_ in each of the child's attributes --> 
                <xsl:for-each select="$sectionTag/*">
                    <xsl:message select="."></xsl:message>
                    <xsl:variable name="element">
                        <xsl:call-template name="elementMake">
                            <xsl:with-param name="res" select="$res"/>
                            <xsl:with-param name="varList" select="$varList"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:message select="$element"/>
                    <xsl:apply-templates select="$element">
                        <xsl:with-param name="result" select="." tunnel="yes"/>
                        <xsl:with-param name="varList" select="$varList" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </section>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Template for varText (only expected to be within a mirrorSection --> 
    <!-- Replace the vars used in varText with the data from the given result --> 
    <xsl:template match="//*[local-name() = 'varText']">
        <para><xsl:value-of select="@message"/></para>
    </xsl:template>
    
    <xsl:template name="multipleReplace">
        <xsl:param name="result" tunnel="yes"/>
        <xsl:param name="varList" tunnel="yes"/>
        <xsl:param name="val"/>
        <xsl:variable name="res">
            <xsl:for-each select="tokenize($val, ' ')">
                <xsl:variable name="out">
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="."/>
                        <xsl:with-param name="result" select="$result"/>
                        <xsl:with-param name="varList" select="$varList"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="string($out)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$res"/>
    </xsl:template>
   
   <!-- Template for creating the elements with their attr values replaced with vars -->
    <xsl:template name="elementMake">
        <xsl:param name="res"/>
        <xsl:param name="varList"/>
        <xsl:element name="{name()}">
            <xsl:call-template name="attrReplace">
                <xsl:with-param name="varList" select="$varList"/>
                <xsl:with-param name="res" select="$res"/>
            </xsl:call-template>
            <xsl:value-of select="."/>
            <xsl:for-each select="./*">
                <xsl:call-template name="elementMake">
                    <xsl:with-param name="varList" select="$varList"/>
                    <xsl:with-param name="res" select="$res"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- Replace vars in all a given element's attributes -->
    <xsl:template name="attrReplace">
        <xsl:param name="res"/>
        <xsl:param name="varList"/>
        <xsl:for-each select="attribute::*">
            <xsl:variable name="attVal"><xsl:value-of select="."/></xsl:variable>
            <xsl:attribute name="{name()}">
                <xsl:call-template name="multipleReplace">
                    <xsl:with-param name="result" select="$res" tunnel="yes"/>
                    <xsl:with-param name="varList" select="$varList" tunnel="yes"/>
                    <xsl:with-param name="val" select="$attVal"/>
                </xsl:call-template>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Returns the static text if string isn't a part of the varList 
         otherwise open result and get the value from it.
         Variables are expected to be _varName_ 
         VarList is expected to be _var1_|_var2_|... -->
    <xsl:template name="varReplace">
        <xsl:param name="val"/>
        <xsl:param name="result"/>
        <xsl:param name="varList"/>
        <xsl:choose>
            <!-- Check if the val is within the valid list of variable names -->
            <xsl:when test="matches($val, $varList)">
                <xsl:variable name="var" select="substring-before(substring-after($val, '_'), '_')"/>
                <xsl:variable name="resultVal">
                    <xsl:value-of select="$result/*[@name = $var]/*"/>
                </xsl:variable>
                <xsl:value-of select="replace($val, concat(concat('_', $var), '_'), $resultVal)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>