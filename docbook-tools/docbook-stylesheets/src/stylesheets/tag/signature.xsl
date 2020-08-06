<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    exclude-result-prefixes="#all" version="2.0">

    <!--Replace the signature tag with a signature page (in the form of an article) -->
    <xsl:template match="//*[local-name() = 'signaturePage']">
        <xsl:param name="date" tunnel="yes"/>
        <article>
            <title>Signature Page</title>
            <xsl:call-template name="signatureList">
                <xsl:with-param name="date" select="$date" tunnel="yes"/>
            </xsl:call-template>
        </article>
    </xsl:template>

    <xsl:template name="signatureList" match="//*[local-name() = 'signatureList']">
        <xsl:param name="date" tunnel="yes"/>
        <xsl:for-each select="./*[local-name() = 'signature']">
            <simplelist type="horiz" columns="2">
                <member>
                    <!-- Signature? -->
                </member>
                <member>
                    <xsl:choose>
                        <xsl:when test="@date = 'today'">
                            <xsl:value-of select="$date"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@date"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </member>
                <member>____________________________</member>
                <member>___________________</member>
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
                <member>Date</member>
            </simplelist>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
