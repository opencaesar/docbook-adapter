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
        <xsl:for-each select="document($frameFile)/*/*/*[local-name() = 'result']">
            <!-- Create a section with the title -->
            <section>
                <title>
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="$sectionTag/@title"/>
                        <xsl:with-param name="result" select="."/>
                    </xsl:call-template>
                </title>
            </section>
            <xsl:apply-templates select="$sectionTag/*">
                <xsl:with-param name="result" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Template for varText (only expected to be within a mirrorSection --> 
    <!-- Replace the vars used in varText with the data from the given result --> 
    <xsl:template match="descendant::*[local-name() = 'mirrorSection']/*[local-name() = 'varText']">
        <xsl:param name="result"/>
        <xsl:message>Reached</xsl:message>
        <xsl:variable name="message"><xsl:value-of select="@message"/></xsl:variable>
        <xsl:variable name="var"><xsl:value-of select="@var"/></xsl:variable>
        <xsl:variable name="resultVal">
            <xsl:value-of select="$result/*[@name = substring-before(substring-after($var, '_'), '_')]/*"/>
        </xsl:variable>
        <xsl:message select="string($message)"/>
        <xsl:message select="string($var)"/>
        <xsl:message select="string($resultVal)"/>
        <xsl:message select="replace('testing _org_ and _org_.', '_org_', 're')"/>
        <para><xsl:value-of select="replace($message, $var, $resultVal)"/></para>
    </xsl:template>
    
    <!-- Returns the static text if string doesn't start with _$
         if it does start with _$, return its val from the result -->
    <xsl:template name="varReplace">
        <xsl:param name="val"/>
        <xsl:param name="result"/>
        <xsl:choose>
            <xsl:when test="starts-with($val, '_') and ends-with($val, '_')">
                <!-- Starts with $, so retrieve its value from result -->
                <xsl:value-of select="$result/*[@name = substring-before(substring-after($val, '_'), '_')]/*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>