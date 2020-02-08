<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="objectIdentificationWrap">
		<lido:objectIdentificationWrap>
			<lido:titleWrap>
				<lido:titleSet>
					<lido:appellationValue
						lido:pref="preferred">
						<xsl:choose>
							<xsl:when test="mpx:titel">
						 		<xsl:value-of select="mpx:titel" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mpx:sachbegriff" />
							</xsl:otherwise>
						</xsl:choose>
					</lido:appellationValue>
				</lido:titleSet>
			</lido:titleWrap>
			<lido:inscriptionsWrap>
				<!-- TODO -->
			</lido:inscriptionsWrap>
			<lido:repositoryWrap>
				<lido:repositorySet lido:type="current">
					<xsl:choose>
						<xsl:when test="mpx:verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
							<lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019118</lido:legalBodyID>
							<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019118</lido:legalBodyID>
						</xsl:when>
						<!-- verwaltendeInstiution AKu untested -->
						<xsl:when test="mpx:verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
							<lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019014</lido:legalBodyID>
							<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019014</lido:legalBodyID>
						</xsl:when>
					</xsl:choose>
			
					<lido:repositoryName>
						<lido:legalBodyName>
							<lido:appellationValue>
								<xsl:value-of select="mpx:verwaltendeInstitution" />
							</lido:appellationValue>
						</lido:legalBodyName>
					</lido:repositoryName>
					<xsl:apply-templates select="mpx:identNr" />
				</lido:repositorySet>
			</lido:repositoryWrap>

			<!-- A wrapper for the state and edition of the object / work. -->
			<lido:displayStateEditionWrap />

			<lido:objectDescriptionWrap>
				<lido:objectDescriptionSet>
					<lido:descriptiveNoteValue
						xml:lang="de" lido:encodinganalog="onlineBeschreibung">
						<xsl:value-of select="mpx:onlineBeschreibung" />
					</lido:descriptiveNoteValue>
				</lido:objectDescriptionSet>
			</lido:objectDescriptionWrap>

			<lido:objectMeasurementsWrap>
				<lido:objectMeasurementsSet>
					<lido:displayObjectMeasurements>
				<xsl:value-of select="mpx:maßangabe" />
					</lido:displayObjectMeasurements>
				</lido:objectMeasurementsSet>
			</lido:objectMeasurementsWrap>

		</lido:objectIdentificationWrap>
	</xsl:template>


	<!-- 
		Todo: For Datenblatt I recently extracted main IdentNr from mpx records. Sophisticated mapping is still 
		to be implemented here
	-->
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:identNr">
		<lido:workID>
			<!-- not sure this is always the intended sortorder, may want to switch 
				to sort and position -->
			<xsl:attribute name="type">
				<xsl:value-of select="@art" />
			</xsl:attribute>
			<xsl:attribute name="sortorder">
				<xsl:number />
			</xsl:attribute>
			<xsl:value-of select="." />
		</lido:workID>
	</xsl:template>

</xsl:stylesheet>