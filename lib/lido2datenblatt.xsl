<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="lido xsi h">

    <xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
        @Expects LIDO as input 
        @outputs RST Deckblatt as html
    -->


    <xsl:template match="/">
            <html>
                <head>
                    <title>Datenblatt aus LIDO</title>
                    <meta charset="UTF-8" />
                    <style>
                        h2 {
                        padding-top: 20px;
                        }
                    </style>
                </head>
                <body>
                    <xsl:text>[* Inhalte in eckigen Klammern werden auf Datenblatt NICHT angezeigt.]</xsl:text>
                    <xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
                </body>
            </html>
    </xsl:template>



    <!-- DATENBLATT -->

    <xsl:template match="/lido:lidoWrap/lido:lido">
        <xsl:variable name="lidoRecID" select="lido:lidoRecID" />
        <xsl:message>
            <xsl:text>datenblatt-lidoRecID: </xsl:text>
            <xsl:value-of select="$lidoRecID" />
        </xsl:message>

        <!-- INTRO -->
        <xsl:element name="a">
            <xsl:attribute name="name">
                <xsl:value-of select="$lidoRecID" />
            </xsl:attribute>
        </xsl:element>
        <table border="1" width="800">
            <tr>
                <td width="15%"><h4>M+</h4></td>
                <td width="15%"><h4>LIDO</h4></td>
                <td width="70%"><h4>Content</h4></td>
            </tr>
            <tr>
                <td align="center" colspan="3">Descriptive Metadata</td>
            </tr>
            <tr>
                <td>objId</td>
                <td>lidoRedID</td>
                <td><xsl:value-of select="lido:lidoRecID"/></td>
            </tr>
            <tr>
                <td>Sachbegriff</td>
                <td>objectWorkType</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectClassificationWrap/lido:objectWorkTypeWrap/lido:objectWorkType[min(@lido:sortorder)][1]/lido:term"/>
                </td>
            </tr>
            <tr>
                <td>Titel</td>
                <td>title (pref)</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:titleWrap/lido:titleSet/lido:appellationValue[@lido:pref = 'preferred']"/>
                </td>
            </tr>
            <tr>
                <td>Weitere Titel</td>
                <td>title</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:titleWrap/lido:titleSet/lido:appellationValue[not(@lido:pref = 'preferred')]"/>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="3">Administrative Metadata</td>
            </tr>
            <tr>
                <td>MM.Pfadangabe, MM.Dateiname, MM.Erweiterung, mulId</td>
                <td>linkResource [@lido:sortorder = 1]</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]/lido:resourceRepresentation/lido:linkResource"/>
                </td>
            </tr>
            <tr>
                <td>Urheb/Fotograf</td>
                <td>rightsholder</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]/lido:rightsResource[lido:rightsType/lido:term ='Urheber']/lido:rightsHolder/lido:legalBodyName/lido:appellationValue"/>
                </td>
            </tr>
        </table>
        <br/>
    </xsl:template>
</xsl:stylesheet>