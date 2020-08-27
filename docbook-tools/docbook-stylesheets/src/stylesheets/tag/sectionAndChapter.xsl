<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://docbook.org/ns/docbook"
    xmlns:oc="https://opencaesar.github.io/"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:template match="oc:section">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:variable name="frameFile">
            <!-- Frame param is the frame directory
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/><xsl:value-of select="@frame"/>
        </xsl:variable> 
        <xsl:variable name="sectionTag" select="."/>
        <!-- Make a map of vars and a varList entry --> 
        <!-- Variables are used by surrounding _varName_ -->
        <xsl:variable name="varMap">
            <xsl:call-template name="varMap"/>
        </xsl:variable>
        <xsl:for-each select="document($frameFile)/*/*/*[local-name() = 'result']">
            <!-- Context node: row in sparql frame -->
            <!-- Check filter condition --> 
            <xsl:if test="oc:checkFilter($sectionTag, .)">
                <!-- Create a section and call on a template to fill the content-->
                <section>
                    <xsl:call-template name="templateContent">
                        <xsl:with-param name="tag" select="$sectionTag"/>
                        <xsl:with-param name="varMap" select="$varMap"/>
                    </xsl:call-template>
                </section>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="oc:chapter">
        <xsl:param name="frameDir" tunnel="yes"/>
        <xsl:variable name="frameFile">
            <!-- Frame param is the frame directory
                 @frame is the frame attribute with the tag -->
            <xsl:value-of select="$frameDir"/><xsl:value-of select="@frame"/>
        </xsl:variable> 
        <xsl:variable name="chapterTag" select="."/>
        <!-- Make a map of vars and a varList entry --> 
        <!-- Variables are used by surrounding _varName_ -->
        <xsl:variable name="varMap">
            <xsl:call-template name="varMap"/>
        </xsl:variable>
        <xsl:for-each select="document($frameFile)/*/*/*[local-name() = 'result']">
            <!-- Context node: row in sparql frame -->
            <!-- Check filter condition --> 
            <xsl:if test="oc:checkFilter($chapterTag, .)">
                <!-- Create a section and call on a template to fill the content-->
                <chapter>
                    <xsl:call-template name="templateContent">
                        <xsl:with-param name="tag" select="$chapterTag"/>
                        <xsl:with-param name="varMap" select="$varMap"/>
                    </xsl:call-template>
                </chapter>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Tag is a variable holding the chapter or section tag to base the template off of-->
    <!-- @Param varMap: Map containing entries that have name -> value: 
            varList -> var1|var2|...
            @name -> @target 
            -->
    <xsl:template name="templateContent">
        <!-- Context node is a row in the sparql frame -->
        <xsl:param name="tag"/>
        <xsl:param name="varMap"/>
        <xsl:param name="frameDir" tunnel="yes"/>
        <title>
            <xsl:call-template name="varReplace">
                <xsl:with-param name="val" select="$tag/@title"/>
                <xsl:with-param name="result" select="."/>
                <xsl:with-param name="varMap" select="$varMap"/>
            </xsl:call-template>
        </title> 
        <xsl:variable name="res" select="."/>
        <xsl:for-each select="$tag/*">
            <!-- For each child, check for _vars_ in each of the child's attributes -->
            <!-- Context node is now the children of the tag -->
            <xsl:variable name="element">
                <xsl:call-template name="elementMake">
                    <xsl:with-param name="res" select="$res"/>
                    <xsl:with-param name="varMap" select="$varMap"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- Now that the vars are replaced, apply the appropriate template for the element -->
            <xsl:apply-templates select="$element">
                <xsl:with-param name="result" select="$res" tunnel="yes"/>
                <xsl:with-param name="varMap" select="$varMap" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Template for var: Simply ensures that var is not copied over to the output -->
    <xsl:template match="//*[local-name() = 'var']"/>
    
    <!-- Template for making varMap. Template call should wrap this in a variable
         Creates a list of entries with a name attribute. Entries are
         varList -> var1|var2|...
         @name -> @target 
         -->
    <xsl:template name="varMap">
        <!-- First map varList -> varName1|varName2|... -->
        <entry key="varList">
            <xsl:value-of select="./*[local-name() = 'var']/@name" separator="|"/>
        </entry>
        <!-- For each var, map [name -> target] --> 
        <xsl:for-each select="./*[local-name() = 'var']">
            <entry key="{@name}"><xsl:value-of select="@target"/></entry>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Template for creating the elements with their attr values replaced with vars -->
    <xsl:template name="elementMake">
        <xsl:param name="res"/>
        <xsl:param name="varMap"/>
        <xsl:element name="{name()}">
            <!-- Copy the attributes with vars replaced -->
            <xsl:for-each select="attribute::*">
                <xsl:variable name="attVal"><xsl:value-of select="."/></xsl:variable>
                <xsl:attribute name="{name()}">
                    <xsl:call-template name="multipleReplace">
                        <xsl:with-param name="result" select="$res" tunnel="yes"/>
                        <xsl:with-param name="varMap" select="$varMap" tunnel="yes"/>
                        <xsl:with-param name="val" select="$attVal"/>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:for-each>
            <!-- Copy the value of the element to our new element with vars replaced -->
            <!-- <xsl:value-of select="."/> -->
            <xsl:call-template name="multipleReplace">
                <xsl:with-param name="result" select="$res" tunnel="yes"/>
                <xsl:with-param name="varMap" select="$varMap" tunnel="yes"/>
                <xsl:with-param name="val" select="."/>
            </xsl:call-template>
            <!-- Copy and modify the element's children -->
            <xsl:for-each select="./*">
                <xsl:call-template name="elementMake">
                    <xsl:with-param name="varMap" select="$varMap"/>
                    <xsl:with-param name="res" select="$res"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- Does variable replacement for a given string. Analyzed by space separated strings -->
    <xsl:template name="multipleReplace">
        <xsl:param name="result" tunnel="yes"/>
        <xsl:param name="varMap" tunnel="yes"/>
        <xsl:param name="val"/>
        <xsl:variable name="res">
            <!-- Check/replace var in each token -->
            <xsl:for-each select="tokenize($val, ' ')">
                <xsl:variable name="out">
                    <xsl:call-template name="varReplace">
                        <xsl:with-param name="val" select="."/>
                        <xsl:with-param name="result" select="$result"/>
                        <xsl:with-param name="varMap" select="$varMap"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="string($out)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$res"/>
    </xsl:template>
    
    <!-- Returns the static text if string isn't a part of the varList 
         otherwise open result and get the value from it.
         Variables are expected to be _varName_ 
         VarList is expected to be var1|var2|... -->
    <xsl:template name="varReplace">
        <xsl:param name="val"/>
        <xsl:param name="result"/>
        <xsl:param name="varMap"/>
        <xsl:variable name="varList"><xsl:value-of select="$varMap/*[local-name() = 'entry' and @key = 'varList']"/></xsl:variable>
        <!-- Grab the value in between _value_ to check against varList -->
        <xsl:variable name="checkVal" select="substring-before(substring-after($val, '_'), '_')"/>
        <xsl:choose>
            <!-- Check if the val is within the valid list of variable names -->
            <xsl:when test="matches($checkVal, $varList)">
                <xsl:variable name="target">
                    <xsl:value-of select="$varMap/*[local-name() = 'entry' and @key = $checkVal]"/>
                </xsl:variable>
                <xsl:variable name="resultVal">
                    <xsl:value-of select="$result/*[@name = $target]/*"/>
                </xsl:variable>
                <!-- Replace the value with the data from the result -->
                <xsl:value-of select="replace($val, concat(concat('_', $checkVal), '_'), $resultVal)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>