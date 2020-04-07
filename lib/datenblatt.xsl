<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="lido xsi h">

    <xsl:output method="html" name="html" version="1.0"
        encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
    @Expects mpx as input 
         @outputs RST Deckblatt as html for each Schaumagazin in a different file 
    -->


    <xsl:template match="/">
        <xsl:call-template name="examples"/>
        <xsl:call-template name="exhibit">
            <xsl:with-param name="file">Amerika-Schaumagazin.htm</xsl:with-param>
            <xsl:with-param name="exhibit">HUFO - Ersteinrichtung - Amerika (Schaumagazin)</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="exhibit">
            <xsl:with-param name="file">Südsee-Schaumagazin.htm</xsl:with-param>
            <xsl:with-param name="exhibit">HUFO - Ersteinrichtung - Südsee (Schaumagazin)</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="exhibit">
            <xsl:with-param name="file">Afrika-Schaumagazin.htm</xsl:with-param>
            <xsl:with-param name="exhibit">HUFO - Ersteinrichtung - Afrika (Schaumagazin)</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="noExhibit"/>
    </xsl:template>


    <xsl:template name="htmlHead">
        <head>
            <meta charset="UTF-8" />
            <title>Datenblatt v0.3</title>
            <style>h2 {padding-top: 20px;}</style>
        </head>
    </xsl:template>

    <xsl:template name="intro">
        <xsl:text>[* Inhalte in eckigen Klammern werden auf Datenblatt NICHT angezeigt.]</xsl:text>
    </xsl:template>


    <xsl:template name="exhibit">
        <xsl:param name="file" />
        <xsl:param name="exhibit" />
        <xsl:message>
            <xsl:text>datenblatt-exhibit: </xsl:text>
            <xsl:value-of select="$exhibit" />
        </xsl:message>
        
        <xsl:result-document href="{$file}" method="html" encoding="UTF-8">
            <html>
                <xsl:call-template name="htmlHead"/>
                <body>
                    <xsl:call-template name="intro"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:ausstellung = $exhibit]">
                        <xsl:sort select="@objId" data-type="number"/>
                    </xsl:apply-templates>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xsl:template name="noExhibit">
        <xsl:message>
            <xsl:text>datenblatt-exhibit: no exhibit</xsl:text>
        </xsl:message>
        <xsl:result-document href="keineAusstellung.htm" method="html"
            encoding="UTF-8">
            <html>
                <xsl:call-template name="htmlHead"/>
                <body>
                    <xsl:call-template name="intro"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[not(mpx:ausstellung)]">
                        <xsl:sort select="@objId" data-type="number"/>
                    </xsl:apply-templates>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="examples">
        <xsl:message>
            <xsl:text>datenblatt-exhibit: selected examples</xsl:text>
        </xsl:message>
        <xsl:result-document href="Beispiele.htm" method="html"
            encoding="UTF-8">
            <html>
                <xsl:call-template name="htmlHead"/>
                <body>
                    <xsl:call-template name="intro"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '939']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '206054']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '736347']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '848050']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '970052']"/>
                    <!-- AKu -->
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '458415']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '982270']"/>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId = '1714903']"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <!-- DATENBLATT -->

    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
        <xsl:variable name="objId" select="@objId" />
        <xsl:variable name="stdbld" select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:standardbild]" />
        <!-- xsl:message>
            <xsl:text>datenblatt-objId: </xsl:text>
            <xsl:value-of select="$objId" />
        /xsl:message -->

        <!-- INTRO -->
        <xsl:element name="a">
            <xsl:attribute name="name">
                <xsl:value-of select="$objId" />
            </xsl:attribute>
        </xsl:element>
        <table border="0" width="800">
            <tr>
                <td colspan="2">
                    <xsl:call-template name="htmlTitle"/>
                </td>
            </tr>
            <tr>
                <td colspan="2" align="right" valign="top">
                    <xsl:if test="$stdbld">
                        <xsl:element name="img">
                            <xsl:attribute name="style">width: 50%</xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:text>../../pix/</xsl:text>
                                <xsl:value-of select="$stdbld/@mulId" />
                                <xsl:text>.</xsl:text>
                                <xsl:value-of select="$stdbld/mpx:dateiname" />
                                <xsl:text>.</xsl:text>
                                <xsl:value-of select="lower-case($stdbld/mpx:erweiterung)" />
                            </xsl:attribute>
                        </xsl:element>
                        <br/>
                    </xsl:if>
                        <xsl:if test="$stdbld/mpx:urhebFotograf">
                            <xsl:text> Foto: </xsl:text>
                            <xsl:value-of select="$stdbld/mpx:urhebFotograf" />
                        </xsl:if>
                    <br/>
                </td>
            </tr>

            <!-- HERSTELLUNG implizit-->
            <!-- an Herstellung beteiligte PK -->
            <xsl:apply-templates select="mpx:personenKörperschaften[
                @funktion eq 'Hersteller' or 
                @funktion eq 'Maler' or
                @funktion eq 'Künstler']" />

                <xsl:if test="mpx:datierung">
                    <tr>
                        <td>Datierung</td>
                        <td>
                            <xsl:for-each select="mpx:datierung[not (@art) or @art != 'Datierung engl.']">
                                <xsl:sort select="@sort" data-type="number"/>
                                <xsl:choose>
                                    <xsl:when test="@vonJahr and @bisJahr">
                                        <xsl:value-of select="." />
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="@vonJahr" />
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select="@bisJahr" />
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="." />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="@art or @sort">
                                    <xsl:text> [</xsl:text>
                                    <xsl:if test="@art">
                                        <xsl:value-of select="@art" />
                                    </xsl:if>
                                    <xsl:if test="@art and @sort">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                    <xsl:if test="@sort">
                                        <xsl:text>s:</xsl:text>
                                        <xsl:value-of select="@sort" />
                                    </xsl:if>
                                    <xsl:text>]</xsl:text>
                                </xsl:if>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>

            <xsl:if test="mpx:geogrBezug[@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie' or not(@bezeichnung)]">
                <tr>
                    <td valign="top">Geographischer Bezug</td>
                    <td>
                        <xsl:for-each select="mpx:geogrBezug[(@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie') or not(@bezeichnung)]">
                            <xsl:sort select="@sort" data-type="number"/>
                            <xsl:value-of select="." />
                            <xsl:if test="@bezeichnung">
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="@bezeichnung" />
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                            <xsl:if test="@art or @kommentar or @sort">
                                <xsl:text> [</xsl:text>
                                <xsl:if test="@art">
                                    <xsl:text>a: </xsl:text>
                                    <xsl:value-of select="@art" />
                                </xsl:if>
                                <xsl:if test="@art and @kommentar">
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                                <xsl:if test="@kommentar">
                                    <xsl:text>k: </xsl:text>
                                    <xsl:value-of select="@kommentar" />
                                </xsl:if>
                                <xsl:if test="@art or @kommentar and @sort">
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                                <xsl:if test="@sort">
                                    <xsl:text>s: </xsl:text>
                                    <xsl:value-of select="@sort" />
                                </xsl:if>
                                <xsl:text>]</xsl:text>
                            </xsl:if>
                            <xsl:if test="position()!=last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if    test="mpx:geogrBezug[@bezeichnung eq 'Kultur' 
                                or @bezeichnung eq 'Ethnie'
                                or @bezeichnung eq 'Sprachgruppe'
                            ]">
                <tr>
                    <td>Gruppe/Kultur</td>
                    <td>
                        <xsl:for-each select="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
                            <xsl:value-of select="." />
                            <xsl:text> [</xsl:text>
                            <xsl:value-of select="@bezeichnung" />
                            <xsl:text>]</xsl:text>
                            <xsl:if test="position()!=last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <xsl:apply-templates select="mpx:materialTechnik[@art='Ausgabe']" />
            <xsl:apply-templates select="mpx:maßangaben" />
            <xsl:apply-templates select="mpx:onlineBeschreibung" />

            <!-- PROVENIENZ -->
            <tr>
                <td colspan="2">
                    <h2>Provenienz</h2>
                </td>
            </tr>


            <xsl:if test="mpx:personenKörperschaften[
                            @funktion eq 'Sammler' or
                            @funktion eq 'Vorbesitzer' or
                            @funktion eq 'Veräußerer']|mpx:erwerbungVon">
                <tr>
                    <td valign="top">Vorbesitzer</td>
                    <td valign="top">
                        <xsl:for-each select="mpx:personenKörperschaften[
                            @funktion eq 'Sammler' or
                            @funktion eq 'Vorbesitzer' or
                            @funktion eq 'Veräußerer' or
                            @funktion eq 'Vorbesitzer (historische Angabe)']|mpx:erwerbungVon">
                            <xsl:value-of select="."/>
                            <xsl:choose>
                                <xsl:when test="@funktion">
                                    <xsl:text> [</xsl:text>
                                    <xsl:value-of select="@funktion"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise> [erwerbungVon]</xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="position()!=last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>
            <xsl:apply-templates select="mpx:verwaltendeInstitution" />
            <xsl:apply-templates select="mpx:erwerbDatum" />
            <xsl:apply-templates select="mpx:erwerbungsart" />
            <xsl:apply-templates select="mpx:credits" />

            <xsl:apply-templates select="mpx:identNr[not(@art) or @art='Ident. Nr.']" />
            <xsl:if test="count (mpx:identNr) = 1">
                <xsl:apply-templates select="mpx:identNr[@art='Ident. Unternummer']" />
            </xsl:if>

            <xsl:if test="/mpx:museumPlusExport/mpx:multimediaobjekt[
                mpx:verknüpftesObjekt = $objId and 
                lower-case(mpx:veröffentlichen) = 'ja' and
                not(mpx:standardbild)]">
                <tr>
                    <td colspan="2">
                        <h2>Weitere Medien</h2>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <xsl:for-each select="/mpx:museumPlusExport/mpx:multimediaobjekt[
                                mpx:verknüpftesObjekt = $objId and 
                                lower-case(mpx:veröffentlichen) = 'ja' and
                                not(mpx:standardbild)]">
                            <xsl:variable name="pfad">
                                    <xsl:text>../../pix/</xsl:text>
                                    <xsl:value-of select="@mulId" />
                                    <xsl:text>.</xsl:text>
                                    <xsl:value-of select="mpx:dateiname" />
                                    <xsl:text>.</xsl:text>
                                    <xsl:value-of select="lower-case(mpx:erweiterung)" />
                            </xsl:variable>
                            <xsl:element name="img">
                                <xsl:attribute name="style">width: 25%</xsl:attribute>
                                <xsl:attribute name="src">
                                <xsl:value-of select="$pfad"/>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>
            <tr>
                <td colspan="2">
                    <h2>[Unsichtbares]</h2>
                </td>
            </tr>
            <xsl:if test="mpx:sachbegriff[@art = 'Weiterer Sachbegriff']">
                <tr>
                    <td width="140" valign="top">
                        <xsl:text>Weitere Sachbegriffe</xsl:text>
                    </td>
                    <td valign="top">
                        <xsl:for-each select="mpx:sachbegriff[@art = 'Weiterer Sachbegriff']">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="mpx:sachbegriff[@art = 'Sachbegriff engl.']">
                <tr>
                    <td valign="top">
                        <xsl:text>Englischer SB:</xsl:text>
                    </td>
                    <td valign="top">
                        <xsl:for-each select="mpx:sachbegriff[@art = 'Sachbegriff engl.']">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <tr>
                <xsl:variable name="link">
                    <xsl:text>http://smb-digital.de/eMuseumPlus?service=ExternalInterface</xsl:text>
                    <xsl:text>&amp;module=collection&amp;objectId=</xsl:text>
                    <xsl:value-of select="$objId"/>
                    <xsl:text>&amp;viewType=detailView</xsl:text>
                </xsl:variable>
                <td>SMB Digital Link</td>
                <td>
                    <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="$link"/></xsl:attribute>
                        <xsl:value-of select="$link"/>
                    </xsl:element>
                </td>
            </tr>
            <xsl:apply-templates select="mpx:bearbStand" />
            <xsl:apply-templates select="mpx:ausstellung[starts-with(., 'HUFO')]" />
            <xsl:apply-templates select="mpx:sachbegriffHierarchisch" />
            <xsl:apply-templates select="mpx:systematikArt" />
        </table>
        <br />
        <br />
    </xsl:template>


    <!-- TODO: multiple titles and sachbegriffe -->
    <xsl:template name="htmlTitle">
        <xsl:choose>
            <xsl:when test="mpx:verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
                <h1>
                    <xsl:for-each select="mpx:titel|mpx:sachbegriff[not(
                        @art eq 'weiterer Sachbegriff' or 
                        @art eq 'Weiterer Sachbegriff' or 
                        @art eq 'Sachbegriff engl.' or 
                        @art eq 'Alte Bezeichnung')]">
                        <xsl:sort select="@art"/>
                        <xsl:if test="position() &lt; 3">
                            <xsl:value-of select="." />
                            <xsl:text> [</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:if test="@art">
                               <xsl:text> </xsl:text>
                                <xsl:value-of select="@art" />
                            </xsl:if>
                            <xsl:text>]</xsl:text>
                            <xsl:if test="position() &lt; 2 and position() &lt; last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </h1>
            </xsl:when>
            <xsl:when test="mpx:verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
                <xsl:choose>
                    <xsl:when test="mpx:titel and mpx:sachbegriff">
                        <h1><xsl:value-of select="mpx:titel" /> [t]</h1>
                        <h2><xsl:value-of select="mpx:sachbegriff" /> [sb]</h2>
                    </xsl:when>
                    <xsl:when test="not(mpx:titel) and mpx:sachbegriff">
                        <h1><xsl:value-of select="mpx:sachbegriff" /> [sb]</h1>
                    </xsl:when>
                    <xsl:when test="mpx:titel and not(mpx:sachbegriff)">
                        <h1><xsl:value-of select="mpx:titel" /> [t]</h1>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Error: Unknown museum</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        <h3>
            <xsl:text> [objId </xsl:text>
            <xsl:value-of select="@objId" />
            <xsl:text>]</xsl:text>
        </h3>
    </xsl:template>


    <!-- INDIVIDUAL FIELDS -->

    <xsl:template match="mpx:ausstellung">
        <tr>
            <td>Ausstellung</td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
        <tr>
            <td>Sektion</td>
            <td>
                <xsl:value-of select="@sektion" />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:bearbStand">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">BearbStand</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mpx:credits">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Credit</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:erwerbDatum">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Eingangsdatum</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:erwerbungsart">
        <tr>
            <td>Erwerbungsart</td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:identNr">
        <tr>
            <td>Inventarnummer</td>
            <td>
                <xsl:value-of select="." /> 
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:materialTechnik">
        <tr>
            <td>Material/Technik</td>
            <td>
                <xsl:value-of select="." />
                <xsl:text> [Ausgabe]</xsl:text>
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:maßangaben">
        <tr>
            <td>Maße</td>
            <td>
                <xsl:value-of select="." />
                <xsl:text> [</xsl:text>
                    <xsl:value-of select="@typ" />
                <xsl:text>]</xsl:text>
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:onlineBeschreibung">
        <tr>
            <td>Beschreibung [online]</td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:sachbegriffHierarchisch">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Sachbegriff hierarchisch</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:sammlungsobjekt/mpx:personenKörperschaften[not(@funktion eq 'Veräußerer' or @funktion eq 'Sammler')]">
        <tr>
            <td>
                <xsl:value-of select="@funktion"/>
            </td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:sammlungsobjekt/mpx:personenKörperschaften[@funktion = 'Veräußerer' or @funktion = 'Sammler']">
        <tr>
            <td>
                <xsl:value-of select="@funktion"/>
                <xsl:text> [PK]</xsl:text>
            </td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:systematikArt">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">SystematikArt</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:verwaltendeInstitution">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Verwaltende Institution</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="genericRow">
        <xsl:param name="header" />
        <xsl:param name="node" />
        <tr>
            <td valign="top">
                <xsl:value-of select="$header"/>
            </td>
            <td valign="top">
                <xsl:value-of select="$node" />
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>