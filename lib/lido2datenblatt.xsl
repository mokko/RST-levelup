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
                    In dieser Darstellung sind leere Felder leere Zellen in der Tabelle.
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
                <td align="center" colspan="3"><h4>Descriptive Metadata</h4></td>
            </tr>
            <tr>
                <td>objId</td>
                <td>lidoRedID</td>
                <td><xsl:value-of select="lido:lidoRecID"/></td>
            </tr>
            <tr>
                <td align="left" colspan="3"><h5>ObjectClassificationWrap</h5></td>
            </tr>
            <tr>
                <td>Sachbegriff</td>
                <td>objectWorkType</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectClassificationWrap/lido:objectWorkTypeWrap/lido:objectWorkType[min(@lido:sortorder)][1]/lido:term"/>
                </td>
            </tr>
            <tr>
                <td align="left" colspan="3"><h5>ObjectIdentificationWrap</h5></td>
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
                <td align="left" colspan="3"><h5>EventWrap</h5></td>
            </tr>
            <tr>
                <td>Datierung</td>
                <td>event (Herstellung), display date</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:displayDate" />
                </td>
            </tr>
            <tr>
                <td>Datierung</td>
                <td>event (Herstellung), date (earlierst-latest). </td>
                <td>
                    <xsl:if test="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:date/lido:earliestDate 
                        or lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:date/lido:latestDate">
                        <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:date/lido:earliestDate" />
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:date/lido:latestDate" />
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <td colspan="3">In Lido kann es praktisch nur ein Datum pro 
                Event geben. In Lido wird nur M+Datierung mit niedrigstem Sort
                berücksichtigt.
                </td>
            </tr>

            <tr>
                <td>Geogr. Bezug</td>
                <td>eventPlace/display place (Hersteller)</td>
                <td>
                    <xsl:for-each select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventPlace/lido:displayPlace">
                        <xsl:sort select="../@sortorder" data-type="number"/>
                        <xsl:value-of select="." />
                        <xsl:if test="position()!=last()">
                            <xsl:text> &gt; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
            <tr>
                <td colspan="3">nach eventPlace/@sortorder sortiert (von großer Zahl nach kleiner)</td>
            </tr>
            <tr>
                <td>Geogr. Bezug</td>
                <td>eventPlace/place (Hersteller)</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventPlace/lido:place/lido:place/lido:appellationValue" />
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventPlace/lido:place/lido:place/@lido:geographicalEntity" />
                    
                </td>
            </tr>
            <tr>
                <td colspan="3">sortorder bei place fehlt momentan im mpx2lido mapping.</td>
            </tr>
            <tr>
                <td align="center" colspan="3"><h4>Administrative Metadata</h4></td>
            </tr>
            <tr>
                <td>MM.Erweiterung, mulId</td>
                <td>linkResource [@lido:sortorder = 1] entspricht Standardbild</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]/lido:resourceRepresentation/lido:linkResource" />
                </td>
            </tr>
            <tr>
                <td colspan="3">Standardbild in M+ wird zu lido:resourceSet[@sortorder = 1]</td>
            </tr>
            <tr>
                <td>Urheb/Fotograf</td>
                <td>rightsholder (Urheber)</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]/lido:rightsResource[lido:rightsType/lido:term ='Urheber']/lido:rightsHolder/lido:legalBodyName/lido:appellationValue" />
                </td>
            </tr>
        </table>
        <br/>
        <br/>
    </xsl:template>
</xsl:stylesheet>