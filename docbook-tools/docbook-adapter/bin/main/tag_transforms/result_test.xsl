<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="//*[local-name() = 'getTable']">
        testing
        <xsl:result-document href="./test_target/output2.txt" method="text">
            Other info
        </xsl:result-document>
        testing pt 2
    </xsl:template>
</xsl:stylesheet>