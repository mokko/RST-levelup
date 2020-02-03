<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 	xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:mpx="http://www.mpx.org/mpx" 
    exclude-result-prefixes="lido xsi h">

	<xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- 
		@Expects mpx as input 
		@outputs RST Deckblatt as html for each Schaumagazin in a different file 
	
		ROOT	
	-->
	<xsl:template match="/">
		<xsl:call-template name="documentLevel">
			<xsl:with-param name="file">Amerika-Schaumagazin.html</xsl:with-param>
			<xsl:with-param name="exhibit">'HUFO - Ersteinrichtung - Amerika (Schaumagazin)'</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="documentLevel">
			<xsl:with-param name="file">Südsee-Schaumagazin.html</xsl:with-param>
			<xsl:with-param name="exhibit">'HUFO - Ersteinrichtung - Südsee (Schaumagazin)'</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="documentLevel">
			<xsl:with-param name="file">Afrika-Schaumagazin.html</xsl:with-param>
			<xsl:with-param name="exhibit">HUFO - Ersteinrichtung - Afrika (Schaumagazin)</xsl:with-param>
		</xsl:call-template>
    </xsl:template>


	<xsl:template name="documentLevel">
		<xsl:param name="file"/>
		<xsl:param name="exhibit"/>
        <xsl:result-document href="{$file}" method="html" encoding="UTF-8">
            <html>
				<head>
					<title>Datenblatt v0.1</title>
					<meta charset="UTF-8"/>
                    <style>
                        h2 {
                          padding-top: 20px;
                        }
                    </style>
				</head>
				<body>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:ausstellung = $exhibit]">
                       <xsl:sort select="@objId"/>
                    </xsl:apply-templates>
                </body>
            </html>
        </xsl:result-document>
	
	</xsl:template>


	<!-- INTRO -->	
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
        <xsl:message><xsl:value-of select="@objId"/></xsl:message>
		<xsl:variable name="objId" select="@objId"/>
		
					<!--  INTRO -->
                    <xsl:element name="a">
                        <xsl:attribute name="name"><xsl:value-of select="$objId"/></xsl:attribute>
                    </xsl:element> 
					<table border="0" width="800">
                    <tr>
                        <td colspan="2">
                            <h1><xsl:value-of select="mpx:sachbegriff"/> [<xsl:value-of select="$objId"/>]</h1>
                            <xsl:element name="img">
                                <xsl:variable name="stdbld" select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:standardbild]"/>
                                <xsl:attribute name="style">width: 50%</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:text>../shf/Standardbilder/</xsl:text>
                                    <xsl:value-of select="$objId"/>
                                    <xsl:text>.</xsl:text>
                                    <xsl:value-of select="$stdbld/mpx:erweiterung"/>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:text>(Foto: </xsl:text>
                            <xsl:value-of select="$stdbld/mpx:urhebFotograf"/>
                            <xsl:text>)</xsl:text>
                        </td>
                    </tr>

						<!--  IDENTIFIKATION -->
                        <tr>
                            <td colspan="2"><h2>Identifikation</h2></td>
                        </tr>

						<xsl:apply-templates select="mpx:identNr[not(@art) or @art='Ident. Nr.']|mpx:verwaltendeInstitution|mpx:titel"/>

						<tr>
							<td>Sachbegriff</td>
							<td>
								<xsl:for-each  select="mpx:sachbegriff">
									<xsl:value-of select="."/>
									<xsl:if test="position()!=last()">
			                            <xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>	

						
						<xsl:apply-templates select="mpx:onlineBeschreibung"/>

						<!--  HERSTELLUNG -->

                        <tr>
                            <td colspan="2"><h2>Herstellung</h2></td>
                        </tr>
						<xsl:apply-templates select="mpx:maßangaben|mpx:materialTechnik[@art='Ausgabe']"/>

						<xsl:apply-templates select="mpx:datierung"/>
                        <xsl:if test="mpx:geogrBezug[@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie' or not(@bezeichnung)]">
                            <tr>
                                <td>Ort</td>
                                <td>
                                    <xsl:for-each select="mpx:geogrBezug[(@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie') or not(@bezeichnung)]">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="@bezeichnung">
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="@bezeichnung"/>
                                            <xsl:text>)</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="position()!=last()">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if test="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
                            <tr>
                                <td>Ethnie/Gruppe/Kultur</td>
                                <td>
                                    <xsl:for-each select="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
                                        <xsl:value-of select="."/>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </xsl:if>

						<!-- PROVENIENZ -->
                        <tr>
                            <td colspan="2"><h2>Provenienz</h2></td>
                        </tr>

						<xsl:apply-templates select="mpx:erwerbDatum"/>
                        <xsl:apply-templates select="mpx:erwerbungVon|mpx:personenKörperschaften[@funktion = 'Veräußerer']"/>
						<xsl:apply-templates select="mpx:erwerbungsart"/>
                        <xsl:apply-templates select="mpx:personenKörperschaften[@funktion = 'Sammler']"/>

						<!-- RECHTE -->
						<xsl:apply-templates select="mpx:credits"/>

						<!-- AUSSTELLUNG -->
                        <xsl:apply-templates select="mpx:ausstellung[starts-with(., 'HUFO')]"/>
                        
                        <!-- WEITERE MEDIEN -->
                        <tr>
	                        <td colspan="2">
	                        	<xsl:for-each select="mpx:museumPlusExport/mpx:multimediaobjekt[not(mpx:standardbild) and 
	                        		mpx:verknüpftesObjekt = $objId and mpx:veröffentlichen = 'JA']">
		                            <xsl:element name="img">
		                                <xsl:attribute name="style">width: 25%</xsl:attribute>
		                                <xsl:attribute name="src">
		                                    <xsl:text>../shf/freigegeben/</xsl:text>
		                                    <xsl:value-of select="mulId"/>
		                                    <xsl:text>.</xsl:text>
		                                    <xsl:value-of select="mpx:erweiterung"/>
		                                </xsl:attribute>
		                            </xsl:element>
		                            <xsl:text> </xsl:text>
								</xsl:for-each>                        
	                        </td>
                        </tr>
                    </table> 
                    <br/><br/>

	</xsl:template>

    <!-- INDIVIDUAL FIELDS -->

	<xsl:template match="mpx:ausstellung">
        <tr>
            <td colspan="2"><h2>[Ausstellung]</h2></td>
        </tr>
        <tr>
            <td>Ausstellung</td>
            <td><xsl:value-of select="."/></td>
        </tr>
        <tr>
            <td>Sektion</td>
            <td><xsl:value-of select="@sektion"/></td>
        </tr>
    </xsl:template>
    
    
	<xsl:template match="mpx:datierung">
        <td>Datierung</td>
        <td>
            <xsl:choose>
                <xsl:when test="@vonJahr and @bisJahr">
                    <xsl:value-of select="."/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@vonJahr"/>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="@bisJahr"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>
    
    
	<xsl:template match="mpx:credits">
        <tr>
            <td colspan="2"><h2>Rechte</h2></td>
        </tr>
		<tr>
			<td>Credits</td>
			<td><xsl:value-of select="."/></td>	
		</tr>
	</xsl:template>


	<xsl:template match="mpx:identNr">
		<tr>
			<td>Inventarnummer</td>
			<td><xsl:value-of select="."/></td>	
		</tr>
	</xsl:template>

	<xsl:template match="mpx:verwaltendeInstitution">
		<tr>
			<td>Verwaltende Institution</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>

	<xsl:template match="mpx:titel">
		<tr>
			<td>Titel</td>
			<td>
                <xsl:value-of select="."/>
                <xsl:if test="@art">
                    <xsl:text> [</xsl:text>
                    <xsl:value-of select="@art"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </td>
		</tr>
	</xsl:template>
	
	<xsl:template match="mpx:onlineBeschreibung">
		<tr>
			<td>Beschreibung</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>

	<xsl:template match="mpx:maßangaben">
		<tr>
			<td>Maße</td>
			<td>
				<xsl:value-of select="@typ"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>

    <xsl:template match="mpx:sammlungsobjekt/mpx:personenKörperschaften[@funktion = 'Veräußerer']">
		<tr>
			<td>Veräußerer [PK]</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
    </xsl:template>
    
    <xsl:template match="mpx:personenKörperschaften[@funktion = 'Sammler']">
		<tr>
			<td>Sammler [PK]</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
    </xsl:template>

	<xsl:template match="mpx:materialTechnik">
		<tr>
			<td>Material/Technik</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="mpx:erwerbDatum">
		<tr>
			<td>Erwerbsdatum</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>

	<xsl:template match="mpx:erwerbungVon">
		<tr>
			<td>Veräußerer</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>

	<xsl:template match="mpx:erwerbungsart">
		<tr>
			<td>Erwerbungsart</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>	
	
</xsl:stylesheet>