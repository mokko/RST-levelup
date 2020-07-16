<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx">

    <xsl:output method="xml" version="1.0" encoding="UTF-8"
        indent="yes" />
    <xsl:strip-space elements="*" />

    <xsl:template match="/mpx:museumPlusExport">
        <xsl:comment>Nodes in unusual mpx order!</xsl:comment>
        <xsl:copy>
            <!-- xsl:apply-templates select="/mpx:museumPlusExport/mpx:multimediaobjekt[lower-case(mpx:veröffentlichen) eq 'ja']"/-->
            <!-- xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:bearbStand eq 'Daten freigegeben für SMB-digital']"/ -->
            <xsl:for-each select="mpx:sammlungsobjekt[mpx:bearbStand eq 'Daten freigegeben für SMB-digital']">
                <xsl:sort select="@objId" data-type="number"/>
                <xsl:variable name="objId" select="@objId"/>
                <xsl:apply-templates select=".[@objId eq $objId]"/>
                <xsl:apply-templates select="../mpx:multimediaobjekt[lower-case(mpx:veröffentlichen) eq 'ja' 
                    and mpx:verknüpftesObjekt eq $objId]"/>
            </xsl:for-each>
        </xsl:copy>
        <!-- xsl:copy-of select="$vPass1"/ -->    
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
