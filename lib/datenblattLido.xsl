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
                                <xsl:value-of select="lido:linkResource" />
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

        </table>
        <br />
        <br />
    </xsl:template>


    <!-- TODO: multiple titles and sachbegriffe -->
    <xsl:template name="htmlTitle">
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