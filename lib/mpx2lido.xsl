<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:import href="mpx2lido/so.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />


	<xsl:template match="/">
		<lido:lidoWrap
			xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
			<xsl:apply-templates
				select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
		</lido:lidoWrap>
	</xsl:template>


	<!-- Gets called from resourceWrap -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:multimediaobjekt">
		<xsl:message>
			VO
			<xsl:value-of select="mpx:verknüpftesObjekt" />
		</xsl:message>

		<lido:resourceSet>
			<lido:resourceID lido:type="mulId">
				<xsl:value-of select="@mulId" />
			</lido:resourceID>
			<lido:resourceType>
				<lido:term xml:lang="EN">digital image</lido:term>
			</lido:resourceType>
			<lido:rightsResource>
				<lido:rightsHolder>
					<lido:legalBodyName>
						<lido:appellationValue>
							<xsl:value-of
								select="mpx:multimediaPersonenKörperschaft" />
						</lido:appellationValue>
					</lido:legalBodyName>
				</lido:rightsHolder>
				<!-- TODO: I assume the creditline needs to formated differently -->
				<lido:creditLine><xsl:value-of select="mpx:urhebFotograf"/></lido:creditLine>
			</lido:rightsResource>
		</lido:resourceSet>
	</xsl:template>

</xsl:stylesheet>