<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/npx"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:npx="http://www.mpx.org/npx"

	exclude-result-prefixes="mpx npx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- strict push sequence -->

	<xsl:template match="/">
		<shf version="20190927">
			<xsl:comment>
                <xsl:text>Format: 
                (1) without xml attributes;
				(2) repeated values are written as list in single element separated by semicolon 
				(3) NEW qualifiers are either as "value [qualifier]" (aka attributes in post position) or
				(4)	NEW qualifiers in preposition as "qualifier:: value".</xsl:text>
			</xsl:comment>

			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
		</shf>
	</xsl:template>


	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
		<xsl:variable name="objId" select="@objId" />


		<xsl:element name="sammlungsobjekt">
			<!--xsl:attribute name="objId"> <xsl:value-of select="@objId"/> </xsl:attribute -->

			<!-- referenziertes Felder (works only with $objId not with @objId) -->
			<xsl:apply-templates select="mpx:anzahlTeile"/>
            <xsl:apply-templates select="mpx:ausstellung"/>
			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:ausstellung/mpx:objekt[. = $objId]"/>

			<xsl:apply-templates select="
                        mpx:bearbDatum|
                        mpx:credits|
                        mpx:datierung" />

			<!-- erwerbNotizAusgabe-->
			<xsl:if
				test="(mpx:verwaltendeInstitution and mpx:erwerbungsart and mpx:erwerbDatum) or mpx:erwerbNotiz[@Ausgabe]">
				<xsl:element name="erwerbNotizAusgabe">
					<xsl:choose>
						<xsl:when test="mpx:erwerbNotiz[@Ausgabe]">
							<xsl:value-of select="." />
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when
									test="mpx:verwaltendeInstitution and mpx:erwerbDatum and mpx:erwerbungsart">
									<xsl:text>Das </xsl:text>
									<xsl:value-of select="mpx:verwaltendeInstitution" />
									<xsl:text> oder eine Vorgängerinstitution erwarb das Objekt </xsl:text>
									<xsl:value-of select="mpx:erwerbDatum" />
									<xsl:text> durch </xsl:text>
									<xsl:value-of select="mpx:erwerbungsart" />
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:when
									test="mpx:verwaltendeInstitution and mpx:erwerbDatum">
									<xsl:text>Das </xsl:text>
									<xsl:value-of select="mpx:verwaltendeInstitution" />
									<xsl:text> oder eine Vorgängerinstitution erwarb das Objekt </xsl:text>
									<xsl:value-of select="mpx:erwerbDatum" />
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:when
									test="mpx:verwaltendeInstitution and mpx:erwerbungsart">
									<xsl:text>Das </xsl:text>
									<xsl:value-of select="mpx:verwaltendeInstitution" />
									<xsl:text> oder eine Vorgängerinstitution erwarb das Objekt </xsl:text>
									<xsl:value-of select="mpx:erwerbDatum" />
									<xsl:text>.</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:if>

			<xsl:element name="exportdatum">
				<xsl:value-of select="@exportdatum" />
			</xsl:element>

			<!--freigebene Digital Assets-->
            <xsl:if test="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:veröffentlichen eq 'Ja' and not(mpx:standardbild)]">
                <xsl:element name="freigegebeneDA">
                    <xsl:for-each select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId and mpx:veröffentlichen eq 'Ja' and not(mpx:standardbild)]">
                        <xsl:message>
                            <xsl:text>SHF.xsl-Freigegeben: </xsl:text>
                            <xsl:value-of select="@mulId"/>
                        </xsl:message>
                        <xsl:value-of select="@mulId"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>


			<!-- geogrBezug -->		
			<xsl:if test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:geogrBezug">
				<xsl:element name="geogrBezug">
					<xsl:for-each
						select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:geogrBezug">
						<xsl:if test="@art">
							<xsl:value-of select="@art" />
							<xsl:text>:: </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space()" />
						<xsl:if test="@bezeichnung">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@bezeichnung" />
							<xsl:text>]</xsl:text>
						</xsl:if>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>


            <!-- gewicht: auf speziellen Wunsch der SHF ist Gewicht jetzt eigenes Feld und nicht mehr Teil von Maßangabe-->
            <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:maßangaben[@typ eq 'Gewicht']"/>

			
			<xsl:apply-templates select="mpx:handlingVerpackungTransport"/>
			<!-- Hersteller -->
			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:personenKörperschaften[@funktion eq 'Hersteller']" />


			<xsl:element name="identNr">
				<xsl:for-each select="mpx:identNr">
					<xsl:sort select="."/>
					<!-- xsl:message>
						<xsl:value-of select="../@objId" />
						<xsl:text> : </xsl:text>
						<xsl:value-of select="." />
					</xsl:message-->
						<xsl:value-of select="." />
						<xsl:if test="@art">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@art"/>
							<xsl:text>]</xsl:text>
						</xsl:if>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
				</xsl:for-each>
			</xsl:element>
			
			<xsl:apply-templates select="
                mpx:kABeleuchtung|
                mpx:kALuftfeuchtigkeit|
                mpx:kABemLeihfähigkeit|
                mpx:kATemperatur"/>

			<!-- Künstler-->
			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:personenKörperschaften[
				@funktion eq 'Künstler' or @funktion eq 'Objektkünstler' ]" />


			<!-- Quali in the back -->
			<xsl:if test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:maßangaben[@typ ne 'Gewicht']">
				<xsl:element name="maßangaben">
					<xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:maßangaben">
						<xsl:value-of select="normalize-space()" />
						<xsl:if test="@typ">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@typ" />
							<xsl:text>]</xsl:text>
						</xsl:if>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>

			<xsl:apply-templates select="mpx:materialTechnik[@art eq 'Ausgabe']" />

			<xsl:element name="objId">
				<xsl:value-of select="@objId" />
			</xsl:element>

			<xsl:apply-templates select="mpx:onlineBeschreibung" />

			<xsl:if
				test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:sachbegriff">
				<xsl:element name="sachbegriff">
					<xsl:for-each
						select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:sachbegriff">
						<xsl:value-of select="normalize-space()" />
						<xsl:if test="@art">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@art" />
							<xsl:text>]</xsl:text>
						</xsl:if>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>

			<xsl:apply-templates
				select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId]/mpx:standardbild" />

			<xsl:apply-templates
				select="mpx:titel|
                                         mpx:verantwortlich|
                                         mpx:verwaltendeInstitution|
                                         mpx:wGAusVorgaben|
                                         mpx:wGRestzeit_gh|
                                         mpx:wGStänderung|
                                         mpx:wGZustand" />
		</xsl:element>
	</xsl:template>


	<!-- ***ADDITIONAL TEMPLATES ***-->

    
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:maßangaben">
		<xsl:element name="gewicht">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    
	<!-- attributes in consecutive elements position -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:datierung">
		<xsl:element name="{name()}">
			<xsl:value-of select="." />
		</xsl:element>
        <xsl:if test="@bisJahr">
            <xsl:element name="datierungBisJahr">
                <xsl:value-of select="@bisJahr" />
            </xsl:element>
        </xsl:if>
        <xsl:if test="@vonJahr">
            <xsl:element name="datierungVonJahr">
                <xsl:value-of select="@vonJahr" />
            </xsl:element>
        </xsl:if>
	</xsl:template>


	<!-- attributes in consecutive elements position; 
		Pfad ist eigentlich nicht notwendig; ich schicke einfach ein Bild mit dem Dateinamen $objId.$erweiterung
		Anders wird das, wenn ich mehr als ein Bild pro SO schicken will. Das verabreden wir aber erst mit Cornelia
		wenn dieser Export steht.  
	-->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:multimediaobjekt/mpx:standardbild">
		<!-- xsl:element name="standardbild" -->
		<xsl:if test="../mpx:personenKörperschaften">
			<xsl:element name="standardbildUrheber">
				<xsl:value-of select="../mpx:personenKörperschaften" />
			</xsl:element>
		</xsl:if>
	</xsl:template>


	<!-- Hersteller und Künstler-->
	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:personenKörperschaften">
		<!--xsl:message><xsl:value-of select="."/></xsl:message-->
			<xsl:choose>
				<xsl:when test="@funktion = 'Hersteller'">
					<xsl:element name="{lower-case(@funktion)}">
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="@funktion = 'Künstler' or @funktion = 'Objektkünstler'">
					<xsl:element name="künstler">
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
	</xsl:template>


	<!-- no attributes ever -->
	<xsl:template match="
                mpx:anzahlTeile|
                mpx:bearbDatum|
                mpx:credits|
                mpx:handlingVerpackungTransport|
                mpx:kABeleuchtung|
                mpx:kABemLeihfähigkeit|
                mpx:kALuftfeuchtigkeit|
                mpx:kATemperatur|
                mpx:onlineBeschreibung|
                mpx:verantwortlich|
                mpx:verwaltendeInstitution|
                mpx:wGAusVorgaben|
                mpx:wGRestzeit_gh|
                mpx:wGStänderung|
                mpx:wGZustand">
		<xsl:element name="{name()}">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>


	<!-- attributes inside value position -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:titel">
		<xsl:element name="{name()}">
			<xsl:value-of select="." />
			<xsl:if test="@art ne 'Titel'">
				<xsl:text> (</xsl:text>
                    <xsl:value-of select="@art" />
                <xsl:text>)</xsl:text>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- attribute in element -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:materialTechnik[@art eq 'Ausgabe']">
		<xsl:element name="materialTechnikAusgabe">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>



	<!-- Ich nehme hier mal an, dass jedes Objekt immer nur in einer HF Ausstellung 
		zu sehen sein wird; es ist aber durchaus möglich, dass ein Objekt von einer 
		in die andere Ausstellung wechselt, also ist diese Annahme nicht sehr stichhaltig. -->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:ausstellung">
		<xsl:if test="matches(., 'HUFO')">
			<xsl:element name="{name()}">
				<xsl:value-of select="." />
			</xsl:element>
			<xsl:element name="ausstellungSektion">
				<xsl:value-of select="@sektion" />
			</xsl:element>
        </xsl:if>
	</xsl:template>

	<!-- ausstellung as separate entity is attribute as consecutive element position-->
	<xsl:template
		match="/mpx:museumPlusExport/mpx:ausstellung/mpx:objekt">
		<xsl:element name="ausstellung">
			<xsl:value-of select="../mpx:titel" />
		</xsl:element>
		<xsl:element name="ausstellungSektion">
            <xsl:value-of select="@sektion" />
        </xsl:element>
	</xsl:template>
</xsl:stylesheet>
