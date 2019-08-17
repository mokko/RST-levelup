<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/mpx"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- 
	transforms dirty to clean mpx 
	mostly 
	(1) rewrites wiederholfelder so that the single record has multiple attributes
	(2) rewrites Qualifikators as attributes
	
	It also renames a few elements and sorts output according to mpx standard
	-->


	<xsl:template name="oneAttrib">
		<xsl:param name="attrib" />
		<xsl:variable name="short" select="lower-case(substring-after($attrib,name()))"/>
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../$attrib">
				<xsl:attribute name="{$short}">
					<xsl:value-of select="../$attrib" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>


	<xsl:template match="/">
		<museumPlusExport level="clean" version="2.0">
			<xsl:for-each-group select="/museumPlusExport/multimediaobjekt" group-by="@mulId">
				<xsl:sort data-type="number" select="current-grouping-key()" />
					<xsl:apply-templates select=".[@mulId = current-grouping-key()]" />
			</xsl:for-each-group>

			<xsl:for-each-group select="/museumPlusExport/personenKörperschaften" group-by="@kueId">
				<xsl:sort data-type="number" select="current-grouping-key()" />
					<xsl:apply-templates select=".[@kueId = current-grouping-key()]" />
			</xsl:for-each-group>

			<xsl:for-each-group select="/museumPlusExport/sammlungsobjekt" group-by="@objId">
				<xsl:sort data-type="number" select="current-grouping-key()" />
					<xsl:apply-templates select=".[@objId = current-grouping-key()]" />
			</xsl:for-each-group>
		</museumPlusExport>
	</xsl:template>

	
	<!-- MM -->


	<xsl:template match="/museumPlusExport/multimediaobjekt">
		<xsl:variable name="mulId" select="@mulId"/>
		<xsl:element name="{name()}">
			<xsl:attribute name="mulId"><xsl:value-of select="$mulId"/></xsl:attribute>
			<xsl:attribute name="exportdatum"><xsl:value-of select="@exportdatum"/></xsl:attribute>

			<xsl:message>
				<xsl:value-of select="$mulId"/>
			</xsl:message>
			<xsl:for-each-group select="/museumPlusExport/multimediaobjekt[@mulId eq $mulId]/*" group-by="string()">
				<xsl:sort data-type="text" select="name()" />
				<xsl:apply-templates select="."/>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>


	<!-- MM default -->	
	<xsl:template match="/museumPlusExport/multimediaobjekt/*">
		<xsl:element name="{name()}">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	
	<!-- only include standardbild if path in standardbild is the same mume record -->
	<xsl:template match="/museumPlusExport/multimediaobjekt/standardbild">
		<xsl:if test="../multimediaPfadangabe">
			<xsl:variable name="bild">
				<xsl:value-of select="../multimediaPfadangabe" />
				<xsl:text>\</xsl:text>
				<xsl:value-of select="../multimediaDateiname" />
				<xsl:text>.</xsl:text>
				<xsl:value-of select="../multimediaErweiterung" />
			</xsl:variable>
			<xsl:if test=". eq $bild ">
				<xsl:message>
					<xsl:text>STANDARDBILD:</xsl:text>
					<xsl:value-of select="$bild" />
				</xsl:message>
				<xsl:element name="{name()}">
					<xsl:value-of select="." />
				</xsl:element>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<xsl:template match="/museumPlusExport/multimediaobjekt/objId">
		<xsl:message>
			<xsl:text>objId --> verknüpftesObjekt</xsl:text>
		</xsl:message>
		<xsl:element name="verknüpftesObjekt">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>


	<!-- PK -->


	<xsl:template match="/museumPlusExport/personKörperschaft">
		<xsl:variable name="id" select="@kueId"/>
		<xsl:element name="{name()}">
			<xsl:attribute name="kueId"><xsl:value-of select="$id"/></xsl:attribute>
			<xsl:attribute name="exportdatum"><xsl:value-of select="@exportdatum"/></xsl:attribute>

			<xsl:message>
				<xsl:value-of select="$id"/>
			</xsl:message>
			<xsl:for-each-group select="/museumPlusExport/personKörperschaft[@kueId eq $id]/*" group-by="string()">
				<xsl:sort data-type="text"
					select="name()" />
				<xsl:apply-templates select="."/>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>


	<!-- PK default -->	
	<xsl:template match="/museumPlusExport/personKörperschaft/*">
		<xsl:element name="{name()}">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/museumPlusExport/personKörperschaft/datierung">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'datierungArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/personKörperschaft/datierungArt"/>


	<xsl:template match="/museumPlusExport/personKörperschaft/geoBezug">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../geoBezugBezeichnung">
				<xsl:attribute name="bezeichnung">
					<xsl:value-of select="../geoBezugBezeichnung" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="../geoBezugArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../geoBezugArt" />
				</xsl:attribute>
			</xsl:if>
		<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/personKörperschaft/geoBezugBezeichnung"/>
	<xsl:template match="/museumPlusExport/personKörperschaft/geoBezugArt"/>


	<xsl:template match="/museumPlusExport/personKörperschaft/name">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'nameArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/personKörperschaft/nameArt"/>


	<xsl:template match="/museumPlusExport/personKörperschaft/nennform">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'nennformArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/personKörperschaft/nennformArt"/>


	<!-- SO -->


	<xsl:template match="/museumPlusExport/sammlungsobjekt">
		<xsl:variable name="id" select="@objId"/>
		<xsl:element name="{name()}">
			<xsl:attribute name="objId"><xsl:value-of select="$id"/></xsl:attribute>
			<xsl:attribute name="exportdatum"><xsl:value-of select="@exportdatum"/></xsl:attribute>

			<xsl:message>
				<xsl:value-of select="$id"/>
			</xsl:message>
			<xsl:for-each-group select="/museumPlusExport/sammlungsobjekt[@objId eq $id]/*" group-by="string()">
				<xsl:sort data-type="text"
					select="name()" />
				<xsl:apply-templates select="."/>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	

	<!-- SO default -->
	<xsl:template match="/museumPlusExport/sammlungsobjekt/*">
		<xsl:variable name="id" select="../@objId"/>
			<!--xsl:message>
				<xsl:value-of select="name()"/>
			</xsl:message-->
			<xsl:element name="{name()}">
				<xsl:value-of select="." />
			</xsl:element>
	</xsl:template>
	
	
	<!-- rewrite Qualifikator as attribute-->
	<xsl:template match="/museumPlusExport/sammlungsobjekt/andereNr">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../andereNrArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../andereNrArt" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../andereNrBemerkung">
				<xsl:attribute name="bemerkung">
					<xsl:value-of select="../andereNrBemerkung" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/andereNrArt|/museumPlusExport/sammlungsobjekt/andereNrBemerkung"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/datierung">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../datierungArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../datierungArt" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../datierungBemerkung">
				<xsl:attribute name="bemerkung">
					<xsl:value-of select="../datierungBemerkung" />
				</xsl:attribute>
			</xsl:if>

			<!-- TODO: ist da wirklich immer ein Jahr drin oder sind da auch andere Formate erlaubt? Wenn nicht wäre jetzt die Gelegenheit, das umzubenennen-->
			<xsl:if test="../datierungJahrBis">
				<xsl:attribute name="bisJahr">
					<xsl:value-of select="../datierungJahrBis" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if	test="../datierungBisMonat|../datierungMonatBis">
				<xsl:attribute name="bisMonat">
					<xsl:value-of select="../datierungBisMonat|../datierungMonatBis" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../datierungBisTag|../datierungTagBis">
				<xsl:attribute name="bisTag">
					<xsl:value-of select="../datierungBisTag|../datierungTagBis" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../datierungVonJahr|../datierungJahrVon">
				<xsl:attribute name="vonJahr">
					<xsl:value-of select="../datierungVonJahr|../datierungJahrVon" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../datierungVonMonat|../datierungMonatVon">
				<xsl:attribute name="vonMonat">
					<xsl:value-of select="../datierungVonMonat|../datierungMonatVon" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../datierungVonTag|../datierungTagVon">
				<xsl:attribute name="vonTag">
					<xsl:value-of select="../datierungVonTag|../datierungTagVon" />
				</xsl:attribute>
			</xsl:if>

			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/datierungBemerkung
				|/museumPlusExport/sammlungsobjekt/datierungArt
				|/museumPlusExport/sammlungsobjekt/datierungVonTag
				|/museumPlusExport/sammlungsobjekt/datierungTagVon
				|/museumPlusExport/sammlungsobjekt/datierungVonMonat
				|/museumPlusExport/sammlungsobjekt/datierungMonatVon
				|/museumPlusExport/sammlungsobjekt/datierungVonJahr
				|/museumPlusExport/sammlungsobjekt/datierungJahrVon
				|/museumPlusExport/sammlungsobjekt/datierungBisTag
				|/museumPlusExport/sammlungsobjekt/datierungTagBis
				|/museumPlusExport/sammlungsobjekt/datierungBisMonat
				|/museumPlusExport/sammlungsobjekt/datierungMonatBis
				|/museumPlusExport/sammlungsobjekt/datierungJahrBis
	"/>
	
	
	<xsl:template match="/museumPlusExport/sammlungsobjekt/geogrBezug">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../geogrBezugBezeichnung">
				<xsl:attribute name="bezeichnung">
					<xsl:value-of select="../geogrBezugBezeichnung" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="../geogrBezugArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../geogrBezugArt" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="../geogrBezugKommentar">
				<xsl:attribute name="kommentar">
					<xsl:value-of select="../geogrBezugKommentar" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/geogrBezugArt
				|/museumPlusExport/sammlungsobjekt/geogrBezugKommentar
				|/museumPlusExport/sammlungsobjekt/geogrBezugBezeichnung"/>
	

	<xsl:template match="/museumPlusExport/sammlungsobjekt/identNr">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'identNrArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/identNrArt"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/maßangaben">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'maßangabenTyp'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/maßangabenTyp"/>

	
	<xsl:template match="/museumPlusExport/sammlungsobjekt/materialTechnik">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../materialTechnikArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../materialTechnikArt" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../materialTechnikBesonderheit">
				<xsl:attribute name="besonderheit">
					<xsl:value-of select="../materialTechnikBesonderheit" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/materialTechnikBesonderheit|/museumPlusExport/sammlungsobjekt/materialTechnikArt"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/objBezIdentNr">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="oov">
			<xsl:if test="../objBezArt">
				<xsl:attribute name="art">
					<xsl:value-of select="../objBezArt" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../objBezBemerkung">
				<xsl:attribute name="bemerkung">
					<xsl:value-of select="../objBezBemerkung" />
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="../objBezSachbegriff">
				<xsl:attribute name="sachbegriff">
					<xsl:value-of select="../objBezSachbegriff" />
				</xsl:attribute>
			</xsl:if>

			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/objBezSachbegriff|/museumPlusExport/sammlungsobjekt/objBezBemerkung|/museumPlusExport/sammlungsobjekt/objBezArt"/>


	<!-- irregular names? personKörperschaft oder personenKörperschaft -->
	<xsl:template match="/museumPlusExport/sammlungsobjekt/personKörperschaft">
		<xsl:message>
			<xsl:value-of select="name()"/>
		</xsl:message>
		<xsl:element name="{name()}">
			<xsl:if test="../personenArtDesBezugs">
				<xsl:attribute name="art">
					<xsl:value-of select="../personenArtDesBezugs" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="../personKörperschaftFunktion">
				<xsl:attribute name="funktion">
					<xsl:value-of select="../personKörperschaftFunktion" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/personKörperschaftFunktion|/museumPlusExport/sammlungsobjekt/personenArtDesBezugs"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/sachbegriff">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'sachbegriffArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/sachbegriffArt"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/swd">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'swdArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/swdArt"/>


	<xsl:template match="/museumPlusExport/sammlungsobjekt/titel">
		<xsl:call-template name="oneAttrib">
			<xsl:with-param name="attrib" select="'titelArt'" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/museumPlusExport/sammlungsobjekt/titelArt"/>

</xsl:stylesheet>