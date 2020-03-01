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

    <xsl:template match="/lido:lido">
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
        <table border="0" width="800">
            <tr>
                <td colspan="2">
                    <xsl:call-template name="htmlTitle"/>
                </td>
            </tr>
            <tr>
                <td colspan="2" align="right" valign="top">
                    <xsl:if test="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]">
                        <xsl:element name="img">
                            <xsl:attribute name="style">width: 50%</xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]/lido:linkResource" />
                            </xsl:attribute>
                        </xsl:element>
                        <br/>
                    </xsl:if>
                        <xsl:if test="lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet[@lido:sortorder = 1]">
                            <xsl:text> Foto: </xsl:text>
                            <xsl:value-of select="lido:rightsResource[lido:rightsType/lido:term ='Urheber']/lido:rightsHolder/lido:legalBodyName/lido:appellationValue" />
                        </xsl:if>
                    <br/>
                </td>
            </tr>

            <xsl:if test="mpx:sachbegriff[@art = 'Weiterer Sachbegriff']">
                <tr>
                    <td width="140" valign="top">
                        <xsl:text>Weitere Sachbegriffe:</xsl:text>
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
                        <xsl:text>[Englischer SB:</xsl:text>
                    </td>
                    <td valign="top">
                        <xsl:for-each select="mpx:sachbegriff[@art = 'Sachbegriff engl.']">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>]</xsl:text>
                    </td>
                </tr>
            </xsl:if>

            <!-- HERSTELLUNG implizit-->
            <!-- an Herstellung beteiligte PK -->
            <xsl:apply-templates select="mpx:personenKörperschaften[
                @funktion eq 'Hersteller' or 
                @funktion eq 'Maler' or
                @funktion eq 'Künstler']" />

            <xsl:for-each select="mpx:datierung">
                <xsl:sort select="@sort" data-type="number"/>
                <tr>
                    <td></td>
                    <td>
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
                    </td>
                </tr>
            </xsl:for-each>

            <xsl:if test="mpx:geogrBezug[@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie' or not(@bezeichnung)]">
                <tr>
                    <td valign="top">Ort: </td>
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

            <xsl:if    test="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
                <tr>
                    <td>Gruppe/Kultur: </td>
                    <td>
                        <xsl:for-each select="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
                            <xsl:value-of select="." />
                            <xsl:if test="position()!=last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <xsl:apply-templates select="mpx:materialTechnik[@art='Ausgabe']" />
            <xsl:apply-templates select="mpx:maßangaben" />

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
                    <td valign="top">Vorbesitzer:</td>
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
            <xsl:apply-templates select="mpx:erwerbDatum" />
            <xsl:apply-templates select="mpx:erwerbungsart" />

            <!-- RECHTE -->
            <xsl:apply-templates select="mpx:verwaltendeInstitution" />
            <xsl:apply-templates select="mpx:identNr[not(@art) or @art='Ident. Nr.']" />
            <xsl:if test="count (mpx:identNr) = 1">
                <xsl:apply-templates select="mpx:identNr[@art='Ident. Unternummer']" />
            </xsl:if>
            <xsl:apply-templates select="mpx:credits" />
            <xsl:apply-templates select="mpx:onlineBeschreibung" />

            <xsl:if test="/mpx:museumPlusExport/mpx:multimediaobjekt[
                                mpx:verknüpftesObjekt = objId and 
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
                                mpx:verknüpftesObjekt = objId and 
                                lower-case(mpx:veröffentlichen) = 'ja' and
                                not(mpx:standardbild)]">
                            <xsl:variable name="pfad">
                                    <xsl:text>../shf/freigegeben/</xsl:text>
                                    <xsl:value-of select="@mulId" />
                                    <xsl:text>.</xsl:text>
                                    <xsl:value-of select="mpx:erweiterung" />
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
            <xsl:apply-templates select="mpx:bearbStand" />
            <xsl:apply-templates select="mpx:ausstellung[starts-with(., 'HUFO')]" />
            <xsl:apply-templates select="mpx:sachbegriffHierarchisch" />
            <xsl:apply-templates select="mpx:systematikArt" />
            <xsl:apply-templates select="mpx:objekttyp" />
        </table>
        <br />
        <br />
    </xsl:template>


    <!-- TODO: multiple titles and sachbegriffe -->
    <xsl:template name="htmlTitle">
        <xsl:choose>
            <xsl:when test="mpx:verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
                <h1>
                    <xsl:for-each select="mpx:titel">
                        <xsl:value-of select="." />
                        <xsl:text> [t]</xsl:text>
                        <xsl:if test="position()!=last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="mpx:titel and mpx:sachbegriff">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:for-each select="mpx:sachbegriff[not(
                        @art eq 'weiterer Sachbegriff' or 
                        @art eq 'Weiterer Sachbegriff' or 
                        @art eq 'Sachbegriff engl.' or 
                        @art eq 'Alte Bezeichnung')]">
                        <xsl:sort select="@art"/>
                        <xsl:value-of select="." />
                        <xsl:choose>
                            <xsl:when test="@art">
                                <xsl:text> [</xsl:text>
                                <xsl:value-of select="@art" />
                                <xsl:text>]</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> [sb]</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()">
                            <xsl:text>, </xsl:text>
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
            <td>Ausstellung:</td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
        <tr>
            <td>Sektion:</td>
            <td>
                <xsl:value-of select="@sektion" />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:bearbStand">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">BearbStand:</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mpx:credits">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Credit:</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:erwerbDatum">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Erwerbsdatum:</xsl:with-param>
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
            <td>Inventarnummer: </td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:materialTechnik">
        <tr>
            <td></td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:maßangaben">
        <tr>
            <td></td>
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
            <td></td>
            <td>
                <xsl:value-of select="." />
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="mpx:sachbegriffHierarchisch">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">Sachbegriff hierarchisch:</xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="mpx:sammlungsobjekt/mpx:personenKörperschaften[not(@funktion eq 'Veräußerer' or @funktion eq 'Sammler')]">
        <tr>
            <td>
                <xsl:value-of select="@funktion"/>
                <xsl:text>: </xsl:text>
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


    <xsl:template match="mpx:objekttyp">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">objekttyp: </xsl:with-param>
            <xsl:with-param name="node"><xsl:value-of select="." /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mpx:systematikArt">
        <xsl:call-template name="genericRow">
            <xsl:with-param name="header">systematikArt: </xsl:with-param>
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