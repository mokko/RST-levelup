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
			<!-- TODO lido:inscriptionsWrap-->
			<lido:repositoryWrap>
				<lido:repositorySet lido:type="current">
					<lido:repositoryName>
						<xsl:choose>
							<xsl:when test="mpx:verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
								<lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019118</lido:legalBodyID>
								<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019118</lido:legalBodyID>
								<xsl:call-template name="legalBodyName"/>
								<lido:legalBodyWeblink>http://www.smb.museum/em</lido:legalBodyWeblink>
							</xsl:when>
							<!-- verwaltendeInstiution AKu untested -->
							<xsl:when test="mpx:verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
								<lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019014</lido:legalBodyID>
								<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019014</lido:legalBodyID>
								<xsl:call-template name="legalBodyName"/>
								<lido:legalBodyWeblink>http://www.smb.museum/aku</lido:legalBodyWeblink>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message>
									<xsl:text>Error: Unknown Institution</xsl:text>
								</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</lido:repositoryName>

					<!-- lido:workID -->
					<xsl:apply-templates select="mpx:identNr" />
					
					<lido:repositoryLocation lido:politicalEntity="inhabited place">
						<lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7003712</lido:placeID>
						<lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2950159</lido:placeID>
						<lido:namePlaceSet>
							<lido:appellationValue>Berlin</lido:appellationValue>
						</lido:namePlaceSet>
						<lido:partOfPlace lido:politicalEntity="State">
							<lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7003670</lido:placeID>
							<lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2950157</lido:placeID>
							<lido:namePlaceSet>
								<lido:appellationValue>Berlin</lido:appellationValue>
							</lido:namePlaceSet>
							<lido:partOfPlace lido:politicalEntity="nation">
								<lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7000084</lido:placeID>
								<lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2921044</lido:placeID>
								<lido:namePlaceSet>
									<lido:appellationValue>Deutschland</lido:appellationValue>
								</lido:namePlaceSet>
							</lido:partOfPlace>
						</lido:partOfPlace>
					</lido:repositoryLocation>
				</lido:repositorySet>
				
				<!-- 
					TODO
					m3 rst: Versuch Standort im Schaumagazin innerhalb von repositoryLocation zu kodieren, wie von FvH vorgeschlagen. 
					Sollen dann die classification tags entfallen? JA
					
					SPEC: Location of the object, especially relevant for architecture and archaeological sites.
				-->
				<lido:repositorySet lido:type="rst">
					<lido:repositoryLocation>
						<lido:placeID lido:type="URI">daf.rst.hf/Südsee/Fidschi/1/1234 (todo)</lido:placeID>
					</lido:repositoryLocation>
				</lido:repositorySet>
			</lido:repositoryWrap>

			<!-- lido:displayStateEditionWrap: A wrapper for the state and edition of the object / work (optional) -->

			<!-- We could include other descriptions, but we don't - to minimize confusion for RST project -->
			<xsl:apply-templates select="mpx:onlineBeschreibung"/>	
			<xsl:apply-templates select="mpx:maßangaben"/>	
		</lido:objectIdentificationWrap>
	</xsl:template>


	<!-- 
		Todo: (1) For Datenblatt I recently extracted main IdentNr from mpx records. Sophisticated mapping 
		is still to be implemented here
		(2) not sure this is always the intended sortorder, may want to switch to sort and position
	-->
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:identNr">
		<lido:workID>
			<xsl:attribute name="lido:encodinganalog">Ident. Nr.</xsl:attribute>
			<xsl:attribute name="lido:type">Inventory number</xsl:attribute>
			<xsl:if test="@art">
				<xsl:attribute name="lido:label">
					<xsl:value-of select="@art" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="lido:sortorder">
				<xsl:number />
			</xsl:attribute>
			<xsl:value-of select="." />
		</lido:workID>
	</xsl:template>


	<!-- TODO: Filter out "Transportmaße" if any -->
	<xsl:template match="mpx:maßangaben">
		<lido:objectMeasurementsWrap>
			<lido:objectMeasurementsSet>
				<lido:displayObjectMeasurements>
					<xsl:if test="@typ">
						<xsl:value-of select="@typ" />
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
				</lido:displayObjectMeasurements>
				<!-- no lido:objectMeasurements b/c we don't need them for RST project; maybe later -->
			</lido:objectMeasurementsSet>
		</lido:objectMeasurementsWrap>
	</xsl:template>


	<xsl:template match="mpx:onlineBeschreibung">
		<lido:objectDescriptionWrap>
			<lido:objectDescriptionSet>
				<lido:descriptiveNoteValue xml:lang="de" lido:encodinganalog="online Beschreibung">
					<xsl:value-of select="." />
				</lido:descriptiveNoteValue>
			</lido:objectDescriptionSet>
		</lido:objectDescriptionWrap>
	</xsl:template>


	<xsl:template name="legalBodyName">
		<lido:legalBodyName>
			<lido:appellationValue>
				<xsl:value-of select="mpx:verwaltendeInstitution" />
			</lido:appellationValue>
		</lido:legalBodyName>
	</xsl:template>

</xsl:stylesheet>