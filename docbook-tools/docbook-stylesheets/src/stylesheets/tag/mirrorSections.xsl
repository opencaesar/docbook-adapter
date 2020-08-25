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
        <!-- Make a map of vars and a varList entry --> 
        <!-- Variables are used by surrounding _varName_ -->
        <xsl:variable name="varMap">
           <!-- First map varList -> _varName1_|_varName2_|.. -->
           <entry key="varList">
               <xsl:value-of select="./*[local-name() = 'var']/@name" separator="|"/>
           </entry>
            <!-- For each var, map name -> target --> 
            <xsl:for-each select="./*[local-name() = 'var']">
                <entry key="{@name}"><xsl:value-of select="@target"/></entry>
            </xsl:for-each>
        </xsl:variable>
        <xsl:message select="$varMap"/>
        <xsl:for-each select="document($frameFile)/*/*/*[local-name() = 'result']">
            <xsl:variable name="res" select="."/>
            <!-- Create a section with the title -->
            <section>
                <title>
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="$sectionTag/@title"/>
                        <xsl:with-param name="result" select="."/>
                        <xsl:with-param name="varMap" select="$varMap"/>
                    </xsl:call-template>
                </title>
                <!-- For each child, check for _vars_ in each of the child's attributes --> 
                <xsl:for-each select="$sectionTag/*">
                    <xsl:variable name="element">
                        <xsl:call-template name="elementMake">
                            <xsl:with-param name="res" select="$res"/>
                            <xsl:with-param name="varMap" select="$varMap"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:apply-templates select="$element">
                        <xsl:with-param name="result" select="." tunnel="yes"/>
                        <xsl:with-param name="varMap" select="$varMap" tunnel="yes"/>
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
    
    <xsl:template match="//*[local-name() = 'var']"/>
    
    
    <xsl:template name="multipleReplace">
        <xsl:param name="result" tunnel="yes"/>
        <xsl:param name="varMap" tunnel="yes"/>
        <xsl:param name="val"/>
        <xsl:variable name="res">
            <xsl:for-each select="tokenize($val, ' ')">
                <xsl:variable name="out">
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="."/>
                        <xsl:with-param name="result" select="$result"/>
                        <xsl:with-param name="varMap" select="$varMap"/>
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
        <xsl:param name="varMap"/>
        <xsl:element name="{name()}">
            <xsl:call-template name="attrReplace">
                <xsl:with-param name="varMap" select="$varMap"/>
                <xsl:with-param name="res" select="$res"/>
            </xsl:call-template>
            <xsl:value-of select="."/>
            <xsl:for-each select="./*">
                <xsl:call-template name="elementMake">
                    <xsl:with-param name="varMap" select="$varMap"/>
                    <xsl:with-param name="res" select="$res"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- Replace vars in all a given element's attributes -->
    <xsl:template name="attrReplace">
        <xsl:param name="res"/>
        <xsl:param name="varMap"/>
        <xsl:for-each select="attribute::*">
            <xsl:variable name="attVal"><xsl:value-of select="."/></xsl:variable>
            <xsl:attribute name="{name()}">
                <xsl:call-template name="multipleReplace">
                    <xsl:with-param name="result" select="$res" tunnel="yes"/>
                    <xsl:with-param name="varMap" select="$varMap" tunnel="yes"/>
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
        <xsl:param name="varMap"/>
        <!-- <xsl:message select="$varMap">Vars</xsl:message> -->
        <xsl:variable name="varList"><xsl:value-of select="$varMap/*[local-name() = 'entry' and @key = 'varList']"/></xsl:variable>
        <xsl:variable name="checkVal" select="substring-before(substring-after($val, '_'), '_')"/>
        <xsl:choose>
            <!-- Check if the val is within the valid list of variable names -->
            <xsl:when test="matches($checkVal, $varList)">
                <xsl:variable name="target">
                    <xsl:value-of select="$varMap/*[local-name() = 'entry' and @key = $checkVal]"/>
                </xsl:variable>
                <xsl:message select="$target"/>
                <xsl:variable name="resultVal">
                    <xsl:value-of select="$result/*[@name = $target]/*"/>
                </xsl:variable>
                <xsl:value-of select="replace($val, concat(concat('_', $checkVal), '_'), $resultVal)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>