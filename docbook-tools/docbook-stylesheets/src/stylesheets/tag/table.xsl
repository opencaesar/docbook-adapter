<?xml version="1.0" encoding="UTF-8"?>
<!-- <getTable frame="query1.frame" title="Table" colList="component$mass"/> -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    xmlns:oc="https://opencaesar.github.io/"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Given a frame and columns, genereate a table -->
    <xsl:template match="oc:table" name="createTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <!-- First create body to check if it is empty or not -->
        <xsl:variable name="tableBody">
            <xsl:call-template name="tableBody"/>
        </xsl:variable>
        <!-- Only make the table if the number of children in tbody is greater than 0 -->
        <xsl:if test="count($tableBody/*[local-name() = 'tbody']/*) > 0">
            <!-- Title is optional; Use table for title and informalTable otherwise -->
            <xsl:choose>
                <xsl:when test="@title">
                    <table class="getTable" border="0">
                        <!-- Inherit attributes to table --> 
                        <xsl:call-template name="inheritAttributes">
                            <xsl:with-param name="excludeList" select="'filter|title|frame'"/>
                            <xsl:with-param name="target" select="."/>
                        </xsl:call-template>
                        <caption>
                            <xsl:value-of select="@title"/>
                        </caption>
                        <!-- <xsl:call-template name="tableBody"/> -->
                        <xsl:copy-of select="$tableBody"/>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <informaltable class="getTable" border="0">
                        <!-- Inherit attributes to table --> 
                        <xsl:call-template name="inheritAttributes">
                            <xsl:with-param name="excludeList" select="'filter|title|frame'"/>
                            <xsl:with-param name="target" select="."/>
                        </xsl:call-template>
                        <!-- <xsl:call-template name="tableBody"/> -->
                        <xsl:copy-of select="$tableBody"/>
                    </informaltable>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Creates the table body. -->
    <xsl:template name="tableBody">
        <xsl:param name="frameDir" tunnel="yes"/>
        <!-- Variable holding the entire tag. Used as we change nodes later -->
        <xsl:variable name="tableTag" select="."/>
        <xsl:variable name="framePath">
            <!-- Frame variable is the frame path
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Create table headers -->
        <thead>
            <xsl:call-template name="generateHeader">
                <xsl:with-param name="class" select="'getTableHeader'"/>
                <xsl:with-param name="altColor" select="''"/>
            </xsl:call-template>
        </thead>
        <!-- Create table rows by calling other templates -->
        <tbody>
            <!-- Check for additional headers --> 
            <xsl:apply-templates select="./oc:tableHeader">
                <xsl:with-param name="class" select="'addHeader'"/>
                <xsl:with-param name="altColor" select="'#80bfff'"/>
            </xsl:apply-templates>
            <!-- Generate the body rows -->
            <xsl:call-template name="generateRow">
                <xsl:with-param name="framePath" select="$framePath"/>
                <xsl:with-param name="tableTag" select="$tableTag"/>
            </xsl:call-template>
            <!-- Create nested tables or inline tables --> 
            <xsl:apply-templates select="./*[local-name() = 'nestedTable' or local-name() = 'inlineTable']">
                <xsl:with-param name="frameDir" select="$frameDir" tunnel="yes"/>
                <xsl:with-param name="numCols" select="count($tableTag/oc:column)"/>
            </xsl:apply-templates>
        </tbody>
    </xsl:template>
    
    <!-- Creates a nested table by making a tr that spans all columns of the original table -->
    <xsl:template name="nestedTable" match="oc:nestedTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:param name="numCols"/>
        <tr>
            <td colspan="{$numCols}">
                <xsl:call-template name="createTable">
                    <xsl:with-param name="frameDir" select="$frameDir" tunnel="yes"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    
    <!-- Creates an inline table (which is essentially a bunch of tr elements) -->
    <xsl:template name="inlineTable" match="oc:inlineTable">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:param name="numCols"/>
        <!-- If color is given; use it. Otherwise, use default green -->
        <xsl:variable name="pdfColor">
            <xsl:choose>
                <xsl:when test="@headerColor">
                    <xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise>#BFDFBF</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- If color is given; use it. Otherwise, default to the css --> 
        <xsl:variable name="htmlColor">
            <xsl:choose>
                <xsl:when test="@headerColor">background-color:<xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Create title if given -->
        <xsl:if test="@title">
            <tr class="inlineTitle" style="{$htmlColor}">
                <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
                <th colspan="{$numCols}">
                    <emphasis role="bold"><xsl:value-of select="@title"/></emphasis>
                </th>
            </tr>
        </xsl:if>
        <!-- Creates headers for the table -->
        <xsl:call-template name="generateHeader">
            <xsl:with-param name="class" select="'inlineHeader'"/>
            <xsl:with-param name="altColor" select="'#BFDFBF'"/>
        </xsl:call-template>
        <!-- Path to the frame -->
        <xsl:variable name="inlinePath">
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Creates the table rows -->
        <xsl:call-template name="generateRow">
            <xsl:with-param name="tableTag" select="."/>
            <xsl:with-param name="framePath" select="$inlinePath"/>
        </xsl:call-template>
        <!-- Create nested tables or inline tables --> 
        <xsl:apply-templates select="./*[local-name() = 'nestedTable' or local-name() = 'inlineTable']">
            <xsl:with-param name="frame" select="$frameDir" tunnel="yes"/>
            <xsl:with-param name="numCols" select="$numCols"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Creates th elements with the appropriate data for the headers and
         wraps these elements appropriately-->
    <xsl:template name="generateHeader" match="oc:tableHeader">
        <xsl:param name="class"/>
        <xsl:param name="altColor"/>
        <!-- If color is given; use it. Otherwise, use the given altColor -->
        <xsl:variable name="pdfColor">
            <xsl:choose>
                <xsl:when test="@headerColor">
                    <xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$altColor"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- If color is given; use it. Otherwise, default to the css --> 
        <xsl:variable name="htmlColor">
            <xsl:choose>
                <xsl:when test="@headerColor">background-color:<xsl:value-of select="@headerColor"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Apply the style to the tr -->
        <tr class="{$class}" style="{$htmlColor}">
            <!-- Use a processing instruction for the pdf format --> 
            <xsl:processing-instruction name="dbfo">
                        bgcolor="<xsl:value-of select="$pdfColor"/>"</xsl:processing-instruction>
            <xsl:for-each select="./oc:column">
                <!-- Create the header elements -->
                <th>
                    <!-- Wrap in emphasis to create bold text --> 
                    <emphasis role="bold">
                        <!-- (Choose @name if given, otherewise @target) -->
                        <xsl:choose>
                            <xsl:when test="@name">
                                <xsl:value-of select="@name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@target"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </emphasis>
                </th>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <!-- Creates tr elements with the appropriate data for the table body 
         wrap these elements if needed (such as with tbody)
         Also calls the interleaveTable template -->
    <xsl:template name="generateRow">
        <xsl:param name="framePath"/>
        <xsl:param name="tableTag"/>
        <!-- Organize rows based on the first column's value -->
        <!-- Context node is now the result being looked at -->
        <xsl:for-each select="document($framePath)/*/*/*[local-name() = 'result']">
            <!-- If the result has a binding that matches to any of the column's target att -->
            <!-- Also check if there is a filter, and if it does have one, check if the result passes -->
            <xsl:if test="./*[@name = $tableTag/oc:column/@target] and oc:checkFilter($tableTag, .)">
                <tr>
                    <xsl:call-template name="generateData">
                        <xsl:with-param name="result" select="."/>
                        <xsl:with-param name="tableTag" select="$tableTag"/>
                    </xsl:call-template>
                </tr>
                <!-- Check if there are interleaving tables that are necessary -->
                <xsl:apply-templates select="$tableTag/oc:interleaveTable">
                    <xsl:with-param name="result" select="."/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Create table rows from a different frame interleaved into the main table -->
    <xsl:template name="interleaveTable" match="oc:interleaveTable">
        <!-- Context node: oc:interleaveTable -->
        <xsl:param name="result"/>
        <xsl:param name="frameDir" tunnel="yes"/>
        <!-- Get the path of the new frame -->
        <xsl:variable name="framePath">
            <!-- Frame variable is the frame path
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/>
            <xsl:value-of select="@frame"/>
        </xsl:variable>
        <!-- Create a element with a filter tag that will be used as the filter 
             This is because we cannot alter the attribute of an element already made -->
        <xsl:variable name="filter">
            <oc:filterHold filter="{oc:tableVarReplace(./@filter, $result)}"/>
        </xsl:variable>
        <xsl:variable name="interleaveTag" select="."/>
        <!-- Context node is now the result being looked at -->
        <xsl:for-each select="document($framePath)/*/*/*[local-name() = 'result']">
            <!-- If the result has a binding that matches to any of the column's target att -->
            <!-- Also check if there is a filter, and if it does have one, check if the result passes -->
            <xsl:if test="./*[@name = $interleaveTag/oc:column/@target] and oc:checkFilter($filter/*[local-name() = 'filterHold'], .)">
                <tr style="background-color:#BFDFBF">
                    <xsl:processing-instruction name="dbfo">
                        bgcolor="#BFDFBF"</xsl:processing-instruction>
                    <xsl:call-template name="generateData">
                        <xsl:with-param name="result" select="."/>
                        <xsl:with-param name="tableTag" select="$interleaveTag"/>
                    </xsl:call-template>
                </tr>
            </xsl:if>
        </xsl:for-each>
        <!-- Create nested tables or inline tables --> 
        <xsl:apply-templates select="./*[local-name() = 'nestedTable' or local-name() = 'inlineTable']">
            <xsl:with-param name="frameDir" select="$frameDir" tunnel="yes"/>
            <xsl:with-param name="numCols" select="count($interleaveTag/oc:column)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Create a table data cells based on the data from the SPARQL result -->
    <!-- The results are expected to be wrapped by tr -->
    <xsl:template name="generateData">
        <xsl:param name="tableTag"/>
        <xsl:param name="result"/>
        <xsl:for-each select="$tableTag/oc:column">
            <xsl:variable name="target">
                <xsl:value-of select="@target"/>
            </xsl:variable>
            <xsl:variable name="value">
                <xsl:if test="$result/*[@name = $target]">
                    <xsl:value-of select="normalize-space($result/*[@name = $target]/*)"/>
                </xsl:if>
            </xsl:variable>
            <td>
                <!-- If this column has a link attribute -->
                <xsl:choose>
                    <xsl:when test="./@link">
                        <!-- Get the link address by replacing %target% with data from frame-->
                        <!-- Create a link with $value as its appearing text -->
                        <link linkend='{oc:tableVarReplace(./@link, $result)}'>
                            <xsl:value-of select="$value"/>
                        </link>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Replaces a _columnName_ with the data from a result and returns the string-->
    <xsl:function name="oc:tableVarReplace" as="xs:string">
        <xsl:param name="val"/>
        <xsl:param name="result"/>
        <xsl:variable name="returnVal">
            <xsl:for-each select="tokenize($val, ' ')">
                <!-- Context node: Each token from the value of $val -->
                <xsl:variable name="out">
                    <xsl:choose>
                        <!-- Regex matching $Anything$Anything -->
                        <xsl:when test="matches(., '_.*_.*')">
                            <xsl:variable name="target" select="substring-before(substring-after(., '_'), '_')"/>
                            <xsl:variable name="resultVal">
                                <xsl:value-of select="$result/*[@name = $target]/*"/>
                            </xsl:variable>
                            <xsl:value-of select="replace(., concat(concat('_', $target), '_'), $resultVal)"/>
                        </xsl:when>
                        <!-- If it doesn't match, use the initial value -->
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence select="string($out)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$returnVal"/>
    </xsl:function>
</xsl:stylesheet>
