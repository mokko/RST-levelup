<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="resourceWrap">
		<lido:resourceWrap>
			<xsl:variable name="objId" select="@objId" />
			<xsl:apply-templates select="../mpx:multimediaobjekt[mpx:verknüpftesObjekt = $objId]" />
		</lido:resourceWrap>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">
		<xsl:variable name="objId" select="mpx:verknüpftesObjekt"/>

		<lido:resourceSet>
			<lido:resourceID lido:type="mulId">
				<xsl:value-of select="@mulId" />
			</lido:resourceID>
			<lido:resourceType>
				<lido:term xml:lang="EN">digital image</lido:term>
			</lido:resourceType>
			<xsl:if test="mpx:urhebFotograf">
				<lido:rightsResource>
					<lido:rightsType>Urheber</lido:rightsType>
					<lido:rightsHolder>
						<lido:legalBodyName>
							<lido:appellationValue>
								<xsl:value-of select="mpx:urhebFotograf" />
							</lido:appellationValue>
						</lido:legalBodyName>
					</lido:rightsHolder>
				</lido:rightsResource>
			</xsl:if>
			<lido:rightsResource>
				<lido:rightsType>Nutzungsrechte</lido:rightsType>
				<lido:rightsHolder>
					<lido:legalBodyName>
						<lido:appellationValue>
							<xsl:text>Staatliche Museen zu Berlin, Preußischer Kulturbesitz</xsl:text>
						</lido:appellationValue>
					</lido:legalBodyName>
				</lido:rightsHolder>

				<!-- TODO: Not sure how FD wants the the creditline to be formated; I am trying to copy smb.digital.de, but not exactly. -->
				<lido:creditLine>
					<xsl:if test="mpx:urhebFotograf">
						<xsl:text>Foto: </xsl:text>
						<xsl:value-of select="mpx:urhebFotograf"/>
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="../mpx:sammlungsobjekt[@objId eq $objId]/mpx:verwaltendeInstitution"/>
					<xsl:text> - Preußischer Kulturbesitz</xsl:text>
				</lido:creditLine>
			</lido:rightsResource>
		</lido:resourceSet>
	</xsl:template>


</xsl:stylesheet>