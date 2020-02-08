<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="objectClassificationWrap">
		<lido:objectClassificationWrap>
			<lido:objectWorkTypeWrap>
				<lido:objectWorkType>
					<xsl:attribute name="type">Sachbegriff</xsl:attribute>
					<!-- "Sachbegriff" before "Weiterer Sachbegriff", using position() over xsl:number -->
					<xsl:apply-templates select="mpx:sachbegriff">
						<xsl:sort select="@art" />
					</xsl:apply-templates>
				</lido:objectWorkType>
			</lido:objectWorkTypeWrap>
				<xsl:apply-templates select="mpx:systematikArt" />
		</lido:objectClassificationWrap>
	</xsl:template>


	<!-- 
		20200114: sortorder added, TODO: not sure it's always in the right 
		order, currently known attributes "Sachbegriff" and "weiterer Sachbegriff". 
	-->
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff">
		<lido:term>
			<xsl:attribute name="sortorder"><xsl:value-of
				select="position()" /></xsl:attribute>
			<xsl:value-of select="." />
		</lido:term>
	</xsl:template>
	
	
		<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:systematikArt">
		<lido:classificationWrap>
			<lido:classification type="systematikArt">
				<lido:term>
					<xsl:attribute name="sortorder"><xsl:number /></xsl:attribute>
					<xsl:value-of select="." />
				</lido:term>
			</lido:classification>
		</lido:classificationWrap>
	</xsl:template>
	
</xsl:stylesheet>