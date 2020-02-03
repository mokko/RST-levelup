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
		@outputs RST Deckblatt as html 
	
		ROOT	
		
		geogrBezug sortorder missing in mpx 
		
	-->
	<xsl:template match="/">
        <xsl:result-document href="Amerika-Schaumagazin.html" method="html" encoding="UTF-8">
            <html>
				<header>
					<title>Deckblatt v0.1</title>
					<meta charset="UTF-8"/>
				</header>
				<body>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:ausstellung = 'HUFO - Ersteinrichtung - Amerika (Schaumagazin)']"/>
                </body>
            </html>
        </xsl:result-document>

        <xsl:result-document href="Südsee-Schaumagazin.html" method="html" encoding="UTF-8">
            <html>
				<header>
					<title>Deckblatt v0.1</title>
					<meta charset="UTF-8"/>
				</header>
				<body>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:ausstellung = 'HUFO - Ersteinrichtung - Südsee (Schaumagazin)']"/>
                </body>
            </html>
        </xsl:result-document>

        <xsl:result-document href="Afrika-Schaumagazin.html" method="html" encoding="UTF-8">
            <html>
				<header>
					<title>Deckblatt v0.1</title>
					<meta charset="UTF-8"/>
				</header>
				<body>
                    <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[mpx:ausstellung = 'HUFO - Ersteinrichtung - Afrika (Schaumagazin)']"/>
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
					<h1><xsl:value-of select="mpx:sachbegriff"/> (<xsl:value-of select="$objId"/>)</h1>

					<xsl:element name="img">
						<xsl:variable name="stdbld" select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:standardbild]"/>
						<xsl:attribute name="style">width: 50%</xsl:attribute>
						<xsl:attribute name="src">
							<xsl:text>../shf/Standardbilder/</xsl:text>
							<xsl:value-of select="$stdbld/$objId"/>
							<xsl:text>.</xsl:text>
							<xsl:value-of select="$stdbld/mpx:erweiterung"/>
						</xsl:attribute>
					</xsl:element>

					<table border="1" width="800">
						<!--  IDENTIFIKATION -->
                        <tr>
                            <td colspan="2"><h1>Identifikation</h1></td>
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
                            <td colspan="2"><h1>Herstellung</h1></td>
                        </tr>
						<xsl:apply-templates select="mpx:datierung"/>
						<tr>
							<td>Ort</td>
							<td>
								<xsl:for-each select="mpx:geogrBezug">
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

						<xsl:apply-templates select="mpx:maßangaben|mpx:materialTechnik[@art='Ausgabe']"/>

						<!-- PROVENIENZ -->
                        <tr>
                            <td colspan="2"><h1>Provenienz</h1></td>
                        </tr>

						<xsl:apply-templates select="mpx:erwerbDatum|mpx:erwerbungVon|mpx:erwerbungsart"/>
					</table> 

	</xsl:template>

    <!-- INDIVIDUAL FIELDS -->

	<xsl:template match="mpx:datierung">
        <td>Datierung</td>
        <td>
            <xsl:if test="@vonJahr and @bisJahr">
                <xsl:value-of select="."/>
                <xsl:text>(</xsl:text>
                <xsl:value-of select="@vonJahr"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="@bisJahr"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </td>
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
			<td><xsl:value-of select="."/></td>
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