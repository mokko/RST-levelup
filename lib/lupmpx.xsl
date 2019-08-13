<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/mpx"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="independentsMM">
		<xsl:param name="currentId" />
		<xsl:param name="tag" />

		<xsl:for-each-group
			select="/museumPlusExport/multimediaobjekt[@mulId=$currentId]"
			group-by="name($tag)">

			<xsl:if test="exists ($tag)">
				<xsl:element name="{name($tag)}">
					<xsl:value-of select="$tag" />
				</xsl:element>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template name="independentsPK">
		<xsl:param name="currentId" />
		<xsl:param name="tag" />

		<xsl:for-each-group
			select="/museumPlusExport/personKörperschaft[@kueId=$currentId]"
			group-by="name($tag)">

			<xsl:if test="exists ($tag)">
				<xsl:element name="{name($tag)}">
					<xsl:value-of select="$tag" />
				</xsl:element>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template name="independentsSO">
		<xsl:param name="currentId" />
		<xsl:param name="tag" />

		<xsl:for-each-group
			select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
			group-by="name($tag)">

			<xsl:if test="exists ($tag)">
				<xsl:element name="{name($tag)}">
					<xsl:value-of select="$tag" />
				</xsl:element>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template match="/">
		<museumPlusExport level="clean" version="2.0">
			<!-- schemaLocation temporarily removed -->


			<!-- Multimediaobjekt MM -->


			<xsl:for-each-group
				select="/museumPlusExport/multimediaobjekt[@mulId]"
				group-by="@mulId">
				<xsl:sort data-type="number"
					select="current-grouping-key()" />
				<xsl:variable select="current-grouping-key()"
					name="currentId" />
				<xsl:message>
					<xsl:value-of select=" 'mulId',$currentId" />
				</xsl:message>

				<xsl:if test="@mulId ne '' ">
					<xsl:element name="multimediaobjekt">
						<xsl:attribute name="mulId">
							<xsl:value-of select="$currentId" />
						</xsl:attribute>

						<xsl:attribute name="exportdatum">
							<xsl:for-each-group
							select="/museumPlusExport/multimediaobjekt[@mulId]/@exportdatum"
							group-by=".">
								<xsl:sort data-type="text" order="descending" />
								<xsl:if test="position() = 1">
									<xsl:value-of select="." />
								</xsl:if>
							</xsl:for-each-group>
						</xsl:attribute>

						<xsl:for-each-group
							select="/museumPlusExport/multimediaobjekt[@mulId=$currentId]"
							group-by="multimediaBearbDatum">

							<xsl:if test="exists (multimediaBearbDatum)">
								<xsl:element name="bearbDatum">
									<xsl:value-of select="multimediaBearbDatum" />
								</xsl:element>
							</xsl:if>
						</xsl:for-each-group>

						<xsl:for-each
							select="(
						multimediaAnfertDat,
						multimediaBemerkFoto,
						multimediaDateiname,
						multimediaErweiterung,
						multimediaFarbe,
						multimediaFormat,
						multimediaFotoNegNr,
						multimediaFunktion,
						multimediaInhaltAnsicht,
						multimediaMatTechn,
						multimediaPersonenKörperschaft,
						multimediaPfadangabe,
						multimediaTyp,
						multimediaUrhebFotograf)">
							<xsl:variable name="tag" select="." />

							<xsl:call-template name="independentsMM">
								<xsl:with-param name="currentId"
									select="$currentId" />
								<xsl:with-param name="tag" select="$tag" />
							</xsl:call-template>
						</xsl:for-each>


						<!-- dependentsMM -->
						<xsl:for-each-group
							select="/museumPlusExport/multimediaobjekt[@mulId=$currentId]"
							group-by="standardbild">
							<xsl:if test="multimediaPfadangabe">

								<xsl:variable name="bild">
									<xsl:value-of select="multimediaPfadangabe" />
									<xsl:text>\</xsl:text>
									<xsl:value-of select="multimediaDateiname" />
									<xsl:text>.</xsl:text>
									<xsl:value-of select="multimediaErweiterung" />
								</xsl:variable>
								<!-- only include standardbild if path in standardbild is the same 
									as here -->
								<xsl:if test="standardbild eq $bild ">
									<xsl:message>
										--- STANDARDBILD:
										<xsl:value-of select="$bild" />
									</xsl:message>
									<xsl:element name="standardbild">
										<xsl:value-of select="standardbild" />
									</xsl:element>
								</xsl:if>
							</xsl:if>

						</xsl:for-each-group>


						<xsl:for-each-group
							select="/museumPlusExport/multimediaobjekt[@mulId=$currentId]"
							group-by="objId">
							<xsl:if test="exists (objId)">
								<xsl:element name="verknüpftesObjekt">
									<xsl:value-of select="objId" />
								</xsl:element>
							</xsl:if>
						</xsl:for-each-group>
					</xsl:element>
				</xsl:if>
			</xsl:for-each-group>



			<!-- PK -->



			<xsl:for-each-group
				select="/museumPlusExport/personKörperschaft[@kueId]"
				group-by="@kueId">
				<xsl:sort data-type="number"
					select="current-grouping-key()" />
				<xsl:variable select="current-grouping-key()"
					name="currentId" />
				<xsl:message>
					<xsl:value-of select="$currentId" />
				</xsl:message>

				<xsl:element name="personKörperschaft">
					<xsl:attribute name="kueId">
						<xsl:value-of select="$currentId" />
					</xsl:attribute>

					<xsl:attribute name="exportdatum">
						<xsl:for-each-group
						select="/museumPlusExport/personKörperschaft[@kueId]/@exportdatum"
						group-by=".">
							<xsl:sort data-type="text" order="descending" />
							<xsl:if test="position() = 1">
								<xsl:value-of select="." />
							</xsl:if>
						</xsl:for-each-group>
					</xsl:attribute>


					<xsl:for-each
						select="(artKörpersch,bearbDatum, bemerkungen, berufTätigkeit, biographie
						)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsMM">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<xsl:for-each-group
						select="/museumPlusExport/personKörperschaft[@kueId=$currentId]"
						group-by="datierung">
						<datierung>
							<xsl:for-each select="datierungArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="datierung" />
						</datierung>
					</xsl:for-each-group>


					<xsl:for-each-group
						select="/museumPlusExport/personKörperschaft[@kueId=$currentId]"
						group-by="geoBezug">
						<geogrBezug>
							<xsl:for-each select="geoBezugBezeichnung">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bezeichnung">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="geoBezugArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="geoBezug" />
						</geogrBezug>
					</xsl:for-each-group>


					<xsl:call-template name="independentsMM">
						<xsl:with-param name="currentId"
							select="$currentId" />
						<xsl:with-param name="tag" select="kurzbiographie" />
					</xsl:call-template>


					<xsl:for-each-group
						select="/museumPlusExport/personKörperschaft[@kueId=$currentId]"
						group-by="name">
						<name>
							<xsl:for-each select="nameArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="name" />
						</name>
					</xsl:for-each-group>


					<xsl:call-template name="independentsMM">
						<xsl:with-param name="currentId"
							select="$currentId" />
						<xsl:with-param name="tag" select="nationalität" />
					</xsl:call-template>


					<xsl:for-each-group
						select="/museumPlusExport/personKörperschaft[@kueId=$currentId]"
						group-by="nennform">
						<nennform>
							<xsl:for-each select="nennformArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="nennform" />
						</nennform>
					</xsl:for-each-group>


					<xsl:for-each
						select="(quelle,titelStand, typ, verantwortlich, verknüpftesObjekt)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsMM">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


				</xsl:element>
			</xsl:for-each-group>


			<!-- SAMMLUNGSOBJEKT SO -->


			<xsl:for-each-group
				select="/museumPlusExport/sammlungsobjekt[@objId]" group-by="@objId">
				<xsl:sort data-type="number"
					select="current-grouping-key()" />
				<xsl:variable select="current-grouping-key()"
					name="currentId" />

				<xsl:message>
					<xsl:value-of select="'objId', $currentId" />
				</xsl:message>
				<xsl:element name="sammlungsobjekt">
					<xsl:attribute name="objId">
						<xsl:value-of select="$currentId" />
					</xsl:attribute>

					<xsl:attribute name="exportdatum">
						<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId]/@exportdatum"
						group-by=".">
							<xsl:sort data-type="text" order="descending" />
							<xsl:if test="position() = 1">
								<xsl:value-of select="." />
							</xsl:if>
						</xsl:for-each-group>
					</xsl:attribute>

					<xsl:for-each
						select="(
						abbildungen,
						allgAngabeBeschriftung,
						allgAngabeBeschriftung,
						aktuellerStandort, aktuellerStandort
						)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="andereNr">
						<andereNr>
							<xsl:for-each select="andereNrArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each select="andereNrBemerkung">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bemerkung">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="andereNr" />
						</andereNr>
					</xsl:for-each-group>


					<xsl:for-each
						select="(anzahlTeile, bearbDatum, belichtungszeit, bemerkung, bemerkungSammlung, besetzung, besitzart, blende, credits)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="datierung">
						<datierung>
							<xsl:for-each select="datierungArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each select="datierungBemerkung">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bemerkung">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungBisJahr|datierungJahrBis">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bisJahr">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungBisMonat|datierungMonatBis">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bisMonat">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungBisTag|datierungTagBis">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bisTag">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungVonJahr|datierungJahrVon">
								<xsl:if test=". ne ''">
									<xsl:attribute name="vonJahr">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungVonMonat|datierungMonatVon">
								<xsl:if test=". ne ''">
									<xsl:attribute name="vonMonat">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each
								select="datierungVonTag|datierungTagVon">
								<xsl:if test=". ne ''">
									<xsl:attribute name="vonTag">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:value-of select="datierung" />
						</datierung>
					</xsl:for-each-group>

					<xsl:for-each
						select="(digitalisiert, dokumentation, erwerbDatum, erwerbNotiz, erwerbNr, erwerbungsart, erwerbungVon, farbe, filmtyp, filter, form, format)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="geogrBezug">
						<geogrBezug>
							<xsl:for-each select="geogrBezugBezeichnung">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bezeichnung">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="geogrBezugArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="geogrBezugKommentar">
								<xsl:if test=". ne ''">
									<xsl:attribute name="kommentar">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="geogrBezug" />
						</geogrBezug>
					</xsl:for-each-group>


					<xsl:call-template name="independentsSO">
						<xsl:with-param name="currentId"
							select="$currentId" />
						<xsl:with-param name="tag" select="handling" />
					</xsl:call-template>


					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="identNr">
						<identNr>
							<xsl:for-each select="identNrArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="identNr" />
						</identNr>
					</xsl:for-each-group>


					<xsl:for-each
						select="(ikonographischeBeschreibung,ikonographischeKurzbeschreibung,inhalt, instrumente, inventarNotiz, kamera, kameratyp, kategorieGenre, konvolut, kurzeBeschreibung, langeBeschreibung, leihgeber)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="maßangaben">
						<maßangabe>
							<xsl:for-each select="maßangabenTyp">
								<xsl:if test=". ne ''">
									<xsl:attribute name="typ">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="maßangaben" />
						</maßangabe>
					</xsl:for-each-group>

					<!-- materialTechnik -->
					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="materialTechnik">
						<materialTechnik>
							<xsl:for-each select="materialTechnikArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="materialTechnikBesonderheit">
								<xsl:if test=". ne ''">
									<xsl:attribute name="besonderheit">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="materialTechnik" />
						</materialTechnik>
					</xsl:for-each-group>


					<xsl:for-each
						select="(musikgattung,nadelschliff, objektiv, objekttyp, objStatus)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>


					<!-- Objekt-Objekt-Beziehungen (OOV) -->
					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="objBezIdentNr">
						<xsl:element name="oov">
							<xsl:for-each select="objBezArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each select="objBezBemerkung">
								<xsl:if test=". ne ''">
									<xsl:attribute name="bemerkung">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>

							<xsl:for-each select="objBezSachbegriff">
								<xsl:if test=". ne ''">
									<xsl:attribute name="sachbegriff">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>


							<xsl:value-of select="objBezIdentNr" />
						</xsl:element>
					</xsl:for-each-group>


					<!-- personenKörperschaften -->
					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="personenKörperschaften">
						<personKörperschaft>
							<xsl:for-each select="personenArtDesBezugs">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each
								select="personenKörperschaftenFunktion">
								<xsl:if test=". ne ''">
									<xsl:attribute name="funktion">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="personenKörperschaften" />
						</personKörperschaft>
					</xsl:for-each-group>

					<!-- sachbegriff -->
					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="sachbegriff">
						<sachbegriff>
							<xsl:for-each select="sachbegriffArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="sachbegriff" />
						</sachbegriff>
					</xsl:for-each-group>


					<xsl:for-each
						select="(schnitt,stativ, stelleFilm, ständigerStandort)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>



					<!-- SWD TODO: check if it works, because of different order in m+template! -->
					<xsl:for-each-group
						select="/museumPlusExport/sammlungsobjekt[@objId=$currentId]"
						group-by="swd">
						<swd>
							<xsl:for-each select="swdArt">
								<xsl:if test=". ne ''">
									<xsl:attribute name="art">
										<xsl:value-of select="." />
									</xsl:attribute>
								</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="swd" />
						</swd>
					</xsl:for-each-group>


					<xsl:for-each
						select="(systematikArt,technischeBemerkung, textOriginal, titel, ton, tvNorm, veranstaltung, verantwortlichkeit, verfügbareFormate, verwaltendeInstitution, verwendetesLicht, vorlage, zielgruppe, zusatzgeräte)">
						<xsl:variable name="tag" select="." />

						<xsl:call-template name="independentsSO">
							<xsl:with-param name="currentId"
								select="$currentId" />
							<xsl:with-param name="tag" select="$tag" />
						</xsl:call-template>
					</xsl:for-each>

				</xsl:element>
			</xsl:for-each-group>
		</museumPlusExport>
	</xsl:template>

</xsl:stylesheet>
