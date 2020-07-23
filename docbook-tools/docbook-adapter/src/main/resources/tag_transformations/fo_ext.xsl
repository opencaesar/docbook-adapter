<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="#all" version="2.0">
    <xsl:import href="file:/D:/Users/truongda/Documents/GitHub/docbook-tools/docbook-tools/docbook-adapter/development/docbook_xsl/fo/docbook.xsl"/>
    
    <!-- Tags that will be replaced with the template chnages -->
    <xsl:template xmlns:xi="http://www.w3.org/2001/XInclude" name="header.content"><xsl:param name="pageclass" select="''"/><xsl:param name="sequence" select="''"/><xsl:param name="position" select="''"/><xsl:param name="gentext-key" select="''"/><fo:block><xsl:choose><xsl:when test="$position = 'left'"><fo:block> Left </fo:block><fo:block> Left 2</fo:block></xsl:when><xsl:when test="$position = 'right'"><fo:block> Europa</fo:block><fo:block> Second row</fo:block></xsl:when><xsl:when test="$position = 'center'"><fo:block> Mid </fo:block></xsl:when></xsl:choose></fo:block></xsl:template>
    
</xsl:stylesheet>