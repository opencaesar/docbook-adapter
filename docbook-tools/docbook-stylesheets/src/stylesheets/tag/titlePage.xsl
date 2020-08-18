<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Uses the function copyDataFile from common.xsl 
         common.xsl is not directly imported to avoid duplicate import statements
         common.xsl is instead imported at the all_transformation.xsl level -->

    <!-- Template for formatting the title page -->
    <xsl:template match="//*[local-name() = 'titlepage']">
        <xsl:param name="data" tunnel="yes"/>
        <!-- Copy titlePage to data/title.xml -->
        <xsl:call-template name="copyDataFile">
            <xsl:with-param name="data" select="$data" tunnel="yes"/>
            <xsl:with-param name="fileName" select="'title.xml'"/>
        </xsl:call-template>
        <xsl:apply-templates select="./*"/>
    </xsl:template>

    <!-- Preparer tag: Replace with a signature list -->
    <xsl:template match="//*[local-name() = 'titlepage']/*[local-name() = 'preparer']">
        <simplelist type="vertical" columns="1">
            <member>Prepared by</member>
            <member/>
            <member>____________________________</member>
            <member>
                <simplelist type="inline">
                    <xsl:if test="@name">
                        <member>
                            <xsl:value-of select="@name"/>
                        </member>
                    </xsl:if>
                    <xsl:if test="@role">
                        <member>
                            <xsl:value-of select="@role"/>
                        </member>
                    </xsl:if>
                    <xsl:if test="@group">
                        <member>
                            <xsl:value-of select="@group"/>
                        </member>
                    </xsl:if>
                </simplelist>
            </member>
        </simplelist>
    </xsl:template>

    <!-- Functions below replace our defined tags with docbook tags. This is so we give users 
        more intuitive names to work with, and replace them with actual docbook tags
        to get the rendering to work properly -->

    <!-- Replace docID with the productname docbook tag -->
    <xsl:template match="//*[local-name() = 'titlepage']/*[local-name() = 'docID']">
        <productname>
            <xsl:value-of select="."/>
        </productname>
    </xsl:template>

    <!-- Replace releaseversion with the textobject docbook tag -->
    <xsl:template match="//*[local-name() = 'titlepage']/*[local-name() = 'releaseversion']">
        <textobject>
            <xsl:value-of select="."/>
        </textobject>
    </xsl:template>

    <!-- Replace titleimage with a mediaobject docbook tag -->
    <xsl:template match="//*[local-name() = 'titlepage']/*[local-name() = 'titleimage']">
        <mediaobject>
            <imageobject>
                <xsl:copy-of select="./*"/>
            </imageobject>
        </mediaobject>
    </xsl:template>

    <!-- Replace bottomimage with a imageobject docbook tag -->
    <xsl:template match="//*[local-name() = 'titlepage']/*[local-name() = 'bottomimage']">
        <imageobject>
            <xsl:copy-of select="./*"/>
        </imageobject>
    </xsl:template>

</xsl:stylesheet>
