<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="//*[local-name() = 'mirrorSection']" name="mirrorSection">
        <xsl:param name="frame" tunnel="yes"/>
        <xsl:variable name="framePath">
            <!-- Frame param is the frame directory
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frame"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        
    </xsl:template>
</xsl:stylesheet>