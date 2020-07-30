<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns='http://docbook.org/ns/docbook'
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Template for formatting the title page -->

    <xsl:template match="//*[local-name() = 'titlePage']">
        <xsl:result-document href="./tag_gen/data/title.xml">
            <xsl:copy-of select="."/>
        </xsl:result-document>
        <xsl:apply-templates select="./*"/>
    </xsl:template>
    
    <xsl:template match="//*[local-name() = 'preparer']">
        <simplelist type='vertical' columns='1'>
            <member>Prepared by</member>
            <member></member>            
            <member>____________________________</member>
            <member>
                <simplelist type='inline'>
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
    
</xsl:stylesheet>