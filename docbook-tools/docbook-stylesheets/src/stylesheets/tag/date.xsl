<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:oc="https://opencaesar.github.io/"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Replace the tag with today's date (date that tag replacement was done) -->
    <xsl:template match="oc:date">
        <xsl:param name="date" tunnel="yes"/>
        <xsl:value-of select="$date"/>
    </xsl:template>
</xsl:stylesheet>
