<?xml version="1.0" encoding="UTF-8"?>
<!-- Replace the getString tag with its respective xQuery -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Using the given frame, retrieve the specified data -->
    <xsl:template match="//*[local-name() = 'getValue']">
        <!-- Get the directory holding the frames -->
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:variable name="filePath">
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Extract from the tag the targeted variable values -->
        <xsl:variable name="of">
            <xsl:value-of select="@of"/>
        </xsl:variable>
        <xsl:variable name="where">
            <xsl:value-of select="@where"/>
        </xsl:variable>
        <xsl:variable name="equalsTo">
            <xsl:value-of select="@equalsTo"/>
        </xsl:variable>
        <!-- Go through the results and search for the desired value -->
        <xsl:for-each select="doc($filePath)//*[local-name() = 'result']">
            <xsl:if test="./*[@name = $where]/* = $equalsTo">
                <xsl:value-of select="normalize-space(./*[@name = $of])"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
