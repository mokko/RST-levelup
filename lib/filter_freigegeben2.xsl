<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx">

    <xsl:output method="xml" version="1.0" encoding="UTF-8"
        indent="yes" />
    <xsl:strip-space elements="*" />

    <xsl:template match="/mpx:museumPlusExport">
        <xsl:comment>In normal mpx order</xsl:comment>
        <xsl:variable name="vPass1">
        <xsl:copy>
            <xsl:for-each select="mpx:sammlungsobjekt[mpx:bearbStand eq 'Daten freigegeben für SMB-digital']">
                <xsl:sort select="@objId" data-type="number"/>
                <xsl:variable name="objId" select="@objId"/>
                <xsl:apply-templates select=".[@objId eq $objId]"/>
                <xsl:apply-templates select="../mpx:multimediaobjekt[lower-case(mpx:veröffentlichen) eq 'ja' 
                    and mpx:verknüpftesObjekt eq $objId]"/>
            </xsl:for-each>
        </xsl:copy>
        </xsl:variable>
        <!-- xsl:copy-of select="$vPass1"/ -->    
        <xsl:apply-templates select="$vPass1/*" mode="vsort"/>
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
    </xsl:template>

    <!-- my first multipass (in a very long time) -->    
    <xsl:template match="@*|node()" mode="vsort">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()">
                <xsl:sort select="name()"/>
                <xsl:sort select="@objId" data-type="number"/>
                <xsl:sort select="@mulId" data-type="number"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
