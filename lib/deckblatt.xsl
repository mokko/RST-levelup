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
	-->
	<xsl:template match="/">
				<xsl:apply-templates select="/mpx:museumPlusExport"/>
	</xsl:template>


	<!-- INTRO -->	
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
		<xsl:variable name="file" select="concat(@objId,'.html')"/>
		<xsl:variable name="objId" select="@objId"/>
		
		<xsl:result-document href="{$file}" method="html" encoding="UTF-8">
			<html>
				<header>
					<title>Deckblatt v0.1</title>
					<meta charset="UTF-8"/>
				</header>
				<body>
					<h1><xsl:value-of select="mpx:sachbegriff"/></h1>

					<xsl:element name="img">
						<xsl:variable name="stdbld" select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:standardbild]"/>
						<xsl:attribute name="src">
							<xsl:text>../shf/Standardbilder/</xsl:text>
							<xsl:value-of select="$stdbld/@mulId"/>
							<xsl:text>.</xsl:text>
							<xsl:value-of select="$stdbld/mpx:erweiterung"/>
						</xsl:attribute>
					</xsl:element>

					<table border="1" width="800">
						<tr>
							<td>Identifikation</td>
							<td>Inventarnummer</td>
							<td><xsl:value-of select="mpx:identNr"/></td>	
						</tr>
						<tr>
								<td></td>
								<td>Verwaltende Institution</td>
								<td><xsl:value-of select="mpx:verwaltendeInstitution"/></td>
						</tr>
						<tr>
							<td></td>
							<td>Titel</td>
							<td><xsl:value-of select="mpx:titel"/></td>	
						</tr>
						<tr>
							<td></td>
							<td>Sachbegriff</td>
							<td><xsl:value-of select="mpx:sachbegriff"/></td>	
						</tr>
						<tr>
							<td></td>
							<td>Beschreibung</td>
							<td><xsl:value-of select="mpx:beschreibung"/></td>	
						</tr>


						<tr>
							<td>Herstellung</td>
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

						<tr>
							<td></td>
							<td>Maße</td>
							<td>
								<xsl:value-of select="mpx:maßangaben/@typ"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="mpx:maßangaben"/>
							</td>
						</tr>

						<tr>
							<td></td>
							<td>Material/Technik</td>
							<td><xsl:value-of select="mpx:materialTechnik[@art='Ausgabe']"/></td>
						</tr>


						<tr>
							<td>Provenienz</td>
							<td>Erwerbsdatum</td>
							<td><xsl:value-of select="mpx:erwerbDatum"/></td>
						</tr>
						<tr>
							<td></td>
							<td>Veräußerer</td>
							<td><xsl:value-of select="mpx:erwerbungVon"/></td>
						</tr>
						<tr>
							<td></td>
							<td>Erwerbungsart</td>
							<td><xsl:value-of select="mpx:erwerbungsart"/></td>
						</tr>
					</table> 
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>


</xsl:stylesheet>