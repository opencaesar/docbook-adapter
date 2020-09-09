<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    exclude-result-prefixes="#all"
    version="2.0">
    <import_original/>
    <import_title/>
    <!-- Used for removing the word chapter from the chapter title -->
    <xsl:param name="local.l10n.xml" select="document('')"/>
	<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
	  <l:l10n language="en">
	     <l:context name="title-numbered">
	       <l:template name="chapter" text="%n.&#160;%t"/>
	     </l:context>
	  </l:l10n>
	</l:i18n>
    
    <!-- Tags that will be replaced with the template chnages -->
    <header frame="header_info.xsl"/>
    <footer frame="footer_info.xsl"/>
    
</xsl:stylesheet>