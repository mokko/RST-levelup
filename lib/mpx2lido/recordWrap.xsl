<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="recordWrap">
		<lido:recordWrap>
			<lido:recordID lido:type="local"><xsl:value-of select="@objId" /></lido:recordID>
			<lido:recordType>
				<!-- TODO -->
				<lido:term>single object</lido:term>
			</lido:recordType>
			<lido:recordSource>
				<!-- lido:legalBodyID -->
				<lido:legalBodyName>
					<lido:appellationValue><xsl:value-of select="mpx:verwaltendeInstitution" />
					</lido:appellationValue>
				</lido:legalBodyName>
				<lido:legalBodyWeblink>https://www.smb.museum</lido:legalBodyWeblink>
			</lido:recordSource>
			<lido:recordRights>
				<lido:rightsHolder>
					<!-- TODO ISIL -->
					<lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">info:isil/DE-Mb112</lido:legalBodyID>
					<lido:legalBodyName>
						<lido:appellationValue>Staatliche Museen zu Berlin</lido:appellationValue>
					</lido:legalBodyName>
					<lido:legalBodyWeblink>https://www.smb.museum</lido:legalBodyWeblink>
				</lido:rightsHolder>
			</lido:recordRights>
			<lido:recordInfoSet>
			<!-- LIDO spec: Link of the metadata, e.g., to the object data sheet 
				    (not the same as link of the object).
				 We  want a link to smb-digital.de. Old eMuseum has this format 
				 http://smb-digital.de/eMuseumPlus?service=ExternalInterface&module=collection&objectId=255188&viewType=detailView 
			-->
				<lido:recordInfoLink lido:formatResource="html">
					<xsl:text>http://smb-digital.de/eMuseumPlus?service=ExternalInterface</xsl:text>
					<xsl:text>&amp;module=collection&amp;objectId=</xsl:text>
					<xsl:value-of select="@objId"/>
					<xsl:text>&amp;viewType=detailView</xsl:text>
				</lido:recordInfoLink>
			</lido:recordInfoSet>
		</lido:recordWrap>
	</xsl:template>
</xsl:stylesheet>