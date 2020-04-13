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
                    <table border="0" width="800"><tr><td>
                    In dieser Darstellung sind leere Felder leere Zellen in der Tabelle. 
                    Diese Darstellung folgt in der Reihenfolge und Struktur LIDO, auch wenn
                    sie in erster Spalte M+ Felder anzeigt.</td></tr></table>
                    <xsl:apply-templates select="/lido:lidoWrap/lido:lido">
                        <xsl:sort select="/lido:lidoWrap/lido:lido/lido:lidoRecID"/>
                    </xsl:apply-templates>
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
                <td align="left" colspan="3"><h4>ObjectClassificationWrap</h4></td>
            </tr>
            <tr>
                <td>Sachbegriff</td>
                <td>objectWorkType</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectClassificationWrap/lido:objectWorkTypeWrap/lido:objectWorkType[min(@lido:sortorder)][1]/lido:term"/>
                </td>
            </tr>

            <tr>
                <td align="left" colspan="3"><h4>ObjectIdentificationWrap</h4></td>
            </tr>
            <tr>
                <td>Titel</td>
                <td>title (@pref)</td>
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
                <td>verwaltendeInstitution</td>
                <td>repositorySet [@type=current]/ repositoryName</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:repositoryWrap/lido:repositorySet[@lido:type = 'current']/lido:repositoryName/lido:legalBodyName/lido:appellationValue"/>
                </td>
            </tr>
            <tr>
                <td>IdentNr</td>
                <td>repositorySet [@type=current]/ workID</td>
                <td>
                    <xsl:for-each select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:repositoryWrap/lido:repositorySet[@lido:type = 'current']/lido:workID">
                        <xsl:sort select="@sortorder" data-type="number"/>
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </td>
            </tr>
            <tr>
                <td colspan="3">Es kann mehrere IdentNr.n geben.</td>
            </tr>
            <tr>
                <td>rst STO</td>
                <td>repositorySet[@type=rst]/ repositoryLocation</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:repositoryWrap/lido:repositorySet[@lido:type = 'rst']/lido:repositoryLocation/lido:placeID"/>
                </td>
            </tr>
            <tr>
                <td>Maßangaben</td>
                <td>displayObjectMeasurements</td>
                <td>
                    <xsl:for-each select="lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectMeasurementsWrap/lido:objectMeasurementsSet/lido:displayObjectMeasurements">
                        <xsl:value-of select="."/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>

            <tr>
                <td align="left" colspan="3"><h4>EventWrap: Herstellung</h4></td>
            </tr>
            <tr>
                <td>Datierung</td>
                <td>event, display date</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventDate/lido:displayDate" />
                </td>
            </tr>
            <tr>
                <td>Datierung (@von-@bis)</td>
                <td>date (earlierst-latest)</td>
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
                Event geben. In diesem Lido wird nur M+Datierung mit
                niedrigstem Sort berücksichtigt.
                </td>
            </tr>

            <tr>
                <td>Geogr. Bezug</td>
                <td>display place</td>
                <td>
                    <xsl:for-each select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventPlace">
                        <xsl:sort select="@sortorder" data-type="number" order="descending"/>
                        <xsl:value-of select="lido:displayPlace" />
                        <xsl:if test="position()!=last()">
                            <xsl:text> &gt; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    nach eventPlace@sortorder sortiert (von großer Zahl nach
                    kleiner)
                </td>
            </tr>
            <tr>
                <td>Geogr. Bezug</td>
                <td>place (@lido:geographicalEntity)</td>
                <td>
                    <xsl:for-each select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventPlace">
                        <xsl:sort select="@sortorder" data-type="number" order="descending"/>
                        <xsl:value-of select="lido:place/lido:namePlaceSet/ lido:appellationValue" />
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="lido:place/@lido:geographicalEntity" />
                        <xsl:text>)</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
            <tr>
                <td>Mat/Technik (@Ausgabe)</td>
                <td>displayMaterialsTech</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Herstellung']/lido:eventMaterialsTech/lido:displayMaterialsTech"/>
                </td>
            </tr>

            <tr>
                <td align="left" colspan="3"><h4>EventWrap: Erwerb</h4></td>
            </tr>
            <tr>
                <td>Veräußerer; erwerbungVon</td>
                <td>displayActorInRole</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventActor/lido:displayActorInRole"/>
                </td>
            </tr>
            <tr>
                <td>Datierung</td>
                <td>event, display date</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventDate/lido:displayDate" />
                </td>
            </tr>
            <tr>
                <td>Datierung (@von-@bis)</td>
                <td>date (earlierst-latest)</td>
                <td>
                    <xsl:if test="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventDate/lido:date/lido:earliestDate 
                        or lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventDate/lido:date/lido:latestDate">
                        <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventDate/lido:date/lido:earliestDate" />
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventDate/lido:date/lido:latestDate" />
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <td>Erwerbungsart</td>
                <td>eventMethod</td>
                <td>
                    <xsl:value-of select="lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event[lido:eventType/lido:term = 'Erwerb']/lido:eventMethod/lido:term" />
                </td>
            </tr>
            
            <tr>
                <td align="center" colspan="3"><h4>Administrative Metadata</h4></td>
            </tr>

            <tr>
                <td align="left" colspan="3"><h4>rightsWorkWrap</h4></td>
            </tr>
            <tr>
                <td>Credits?</td>
                <td>rightsWorkSet</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:rightsHolder/lido:legalBodyName/lido:appellationValue" />
                </td>
            </tr>
            <tr>
                <td>Credits</td>
                <td>creditLine (object)</td>
                <td>
                    <xsl:value-of select="lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:creditLine" />
                </td>
            </tr>
            <tr>
                <td align="left" colspan="3"><h4>recordWrap</h4></td>
            </tr>
            <tr>
                <td>smb-digital.de</td>
                <td>recordInfoLink</td>
                <td>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="lido:administrativeMetadata/lido:recordWrap/lido:recordInfoSet/lido:recordInfoLink" />
                        </xsl:attribute>
                        <xsl:value-of select="lido:administrativeMetadata/lido:recordWrap/lido:recordInfoSet/lido:recordInfoLink" />
                    </a>
                </td>
            </tr>

            <tr>
                <td align="left" colspan="3"><h4>resourceWrap</h4></td>
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