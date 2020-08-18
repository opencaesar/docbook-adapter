<?xml version="1.0" encoding="ASCII"?><!--This file was created automatically by html2xhtml--><!--from the HTML stylesheets.--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:d="http://docbook.org/ns/docbook" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" xmlns="http://www.w3.org/1999/xhtml" version="1.0" exclude-result-prefixes="doc d">

<!-- ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or https://cdn.docbook.org/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:import href="docbook.xsl"/>
<xsl:import href="chunk.xsl"/>

<xsl:output method="xml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

<xsl:param name="toc.list.type" select="'tocentry'"/>

<!-- refentry in autotoc.xsl does not use subtoc, so must
     handle it explicitly here. -->
<xsl:template match="d:refentry" mode="toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="subtoc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template name="subtoc">
  <xsl:param name="nodes" select="NOT-AN-ELEMENT"/>
  <xsl:variable name="filename">
    <xsl:apply-templates select="." mode="chunk-filename"/>
  </xsl:variable>

  <xsl:variable name="chunk">
    <xsl:call-template name="chunk"/>
  </xsl:variable>

  <xsl:if test="$chunk != 0">
    <xsl:call-template name="indent-spaces"/>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <d:tocentry linkend="{$id}">
      <xsl:processing-instruction name="dbhtml">
        <xsl:text>filename="</xsl:text>
        <xsl:value-of select="$filename"/>
        <xsl:text>"</xsl:text>
      </xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:apply-templates mode="toc" select="$nodes"/>
      <xsl:call-template name="indent-spaces"/>
    </d:tocentry>
    <xsl:text>
</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="indent-spaces">
  <xsl:param name="node" select="."/>
  <xsl:text>  </xsl:text>
  <xsl:if test="$node/parent::*">
    <xsl:call-template name="indent-spaces">
      <xsl:with-param name="node" select="$node/parent::*"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="/" priority="-1">
  <xsl:text>
</xsl:text>
  <toc role="chunk-toc">
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="/" mode="toc"/>
  </toc>
  <xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>