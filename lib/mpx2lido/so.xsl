<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />


	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
		<lido:lido>

			<!-- 1 LidoRecID -->

			<lido:lidoRecID>
			<xsl:attribute name="lido:source">
				<xsl:value-of select="mpx:verwaltendeInstitution" />
			</xsl:attribute>
			<xsl:attribute name="lido:type">local</xsl:attribute>
				<xsl:value-of select="@objId" />
			</lido:lidoRecID>

			<!-- 3 CATEGORY -->

			<xsl:apply-templates select="mpx:objekttyp" />

			<!-- 4 DESCRIPTIVE METADATA -->
			<lido:descriptiveMetadata xml:lang="de">

				<!-- 4.1 Classification -->
				<lido:objectClassificationWrap>
					<lido:objectWorkTypeWrap>
						<lido:objectWorkType>
							<xsl:attribute name="type">Sachbegriff</xsl:attribute>
							<xsl:apply-templates select="mpx:sachbegriff">
								<!-- "Sachbegriff" before "Weiterer Sachbegriff", using position() 
									over xsl:number -->
								<xsl:sort select="@art" />
							</xsl:apply-templates>
						</lido:objectWorkType>
					</lido:objectWorkTypeWrap>
					<lido:classificationWrap>
						<xsl:if test="mpx:systematikArt">
							<lido:classification type="systematikArt">
								<xsl:apply-templates
									select="mpx:systematikArt" />
							</lido:classification>
						</xsl:if>
					</lido:classificationWrap>
				</lido:objectClassificationWrap>

				<!-- 4.2 Identification -->
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
							<lido:repositoryName>
								<lido:legalBodyName>
									<lido:appellationValue><xsl:value-of
										select="mpx:verwaltendeInstitution" /></lido:appellationValue>
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
			</lido:descriptiveMetadata>

			<!-- 5 Admin MD -->

			<lido:administrativeMetadata
				xml:lang="en">

				<!-- 5.1. Rights for Work -->
				<lido:rightsWorkWrap />

				<!-- 5.2. Record -->
				<lido:recordWrap>
					<lido:recordID lido:type="local"><xsl:value-of
						select="@objId" /></lido:recordID>
					<lido:recordType>
						<!-- TODO -->
						<lido:term>single object</lido:term>
					</lido:recordType>
					<lido:recordSource>
						<!-- lido:legalBodyID -->
						<lido:legalBodyName>
							<lido:appellationValue><xsl:value-of
								select="mpx:verwaltendeInstitution" />
							</lido:appellationValue>
						</lido:legalBodyName>
						<lido:legalBodyWeblink>https://www.smb.museum</lido:legalBodyWeblink>
					</lido:recordSource>
					<lido:recordRights>
						<lido:rightsHolder>
							<!-- TODO ISIL -->
							<lido:legalBodyID lido:type="URI"
								lido:source="ISIL (ISO 15511)">info:isil/DE-Mb112</lido:legalBodyID>
							<lido:legalBodyName>
								<lido:appellationValue>Staatliche Museen zu Berlin</lido:appellationValue>
							</lido:legalBodyName>
							<lido:legalBodyWeblink>https://www.smb.museum</lido:legalBodyWeblink>
						</lido:rightsHolder>
					</lido:recordRights>
					<lido:recordInfoSet>
						<lido:recordInfoLink
							lido:formatResource="html">http://www.bildindex.de/dokumente/html/obj00154983</lido:recordInfoLink>
					</lido:recordInfoSet>
					<lido:recordInfoSet>
						<lido:recordInfoID lido:type="oai">oai:bildindex.de:lidoWrap::DE-Mb112/lido-obj00154983</lido:recordInfoID>
					</lido:recordInfoSet>
				</lido:recordWrap>

				<!-- 5.3. Resource -->
				<lido:resourceWrap>
					<xsl:variable name="objId" select="@objId" />

					<xsl:apply-templates
						select="../mpx:multimediaobjekt[mpx:verknüpftesObjekt = $objId]" />
				</lido:resourceWrap>
			</lido:administrativeMetadata>
		</lido:lido>
	</xsl:template>


	<!-- using objekttyp for main category, but I could also use CIDOC term 
		here -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:objekttyp">
		<lido:category>
			<lido:conceptID lido:type="URI">
				<xsl:text>http://www.mpx.org/concepts/</xsl:text>
				<xsl:value-of select="." />
			</lido:conceptID>
			<lido:term xml:lang="de">
				<xsl:value-of select="." />
			</lido:term>
		</lido:category>
	</xsl:template>


	<!-- 20200114: sortorder added, TODO: not sure it's always in the right 
		order, currently known attributes "Sachbegriff" and "weiterer Sachbegriff". -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff">
		<lido:term>
			<xsl:attribute name="sortorder"><xsl:value-of
				select="position()" /></xsl:attribute>
			<xsl:value-of select="." />
		</lido:term>
	</xsl:template>


	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:systematikArt">
		<lido:term>
			<xsl:attribute name="sortorder"><xsl:number /></xsl:attribute>
			<xsl:value-of select="." />
		</lido:term>
	</xsl:template>


	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:identNr">
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