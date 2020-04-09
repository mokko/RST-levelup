<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- for now I assume there will always be at least one piece of information relating to Herstellung -->
    <xsl:template name="Herstellung">
        <lido:eventSet>
            <lido:displayEvent xml:lang="de">Herstellung</lido:displayEvent>
            <lido:event>
                <lido:eventType>
                    <lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00007</lido:conceptID>
                    <lido:term xml:lang="de">Herstellung</lido:term>
                </lido:eventType>

                <!-- lido: eventActor -->
                <xsl:apply-templates mode="Gruppe" select="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']"/>
                <!-- Todo: There could be a PK@Hersteller -->

                <!-- lido: eventDate 
                SPEC: repeated displayDates only for language variants; 
                according to spec event dates cannot be repeated. AKu often 
                has multiple dates representing multiple estimates.-->

                <xsl:apply-templates select="mpx:datierung[min(@sort)][1]"/>

                <!-- lido: eventPlace -->
                <xsl:apply-templates mode="Ort" select="mpx:geogrBezug[@bezeichnung ne 'Kultur' 
                    and @bezeichnung ne 'Ethnie'
                    and @bezeichnung ne 'Sprachgruppe']"/>

                <xsl:if test="mpx:materialTechnik">
                    <lido:eventMaterialsTech>
                        <xsl:apply-templates select="mpx:materialTechnik[@art eq 'Ausgabe']"/>
                        <xsl:if test="mpx:materialTechnik[@art ne 'Ausgabe']">
                            <lido:materialsTech>
                                <xsl:apply-templates select="mpx:materialTechnik[@art ne 'Ausgabe']"/>
                            </lido:materialsTech>
                        </xsl:if>
                    </lido:eventMaterialsTech>
                </xsl:if>
            </lido:event>
        </lido:eventSet>
    </xsl:template>
    
        <!--  LIDO spec says only one date per event, so let's pick the one with 
    the lowest sort number -->
    <xsl:template match="mpx:datierung">
        <lido:eventDate>
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
            <xsl:if test="@vonJahr or @bisJahr">
                <lido:date>
                    <xsl:if test="@vonJahr">
                        <lido:earliestDate>
                            <xsl:value-of select="@vonJahr"/>
                        </lido:earliestDate>
                    </xsl:if>
                    <xsl:if test="@bisJahr">
                        <lido:latestDate>
                            <xsl:value-of select="@bisJahr"/>
                        </lido:latestDate>
                    </xsl:if>
                </lido:date>
            </xsl:if>
        </lido:eventDate>
    </xsl:template>

    <!-- 
        m3: Kultur auf Actor gemappt entsprechend Vorschlag FvH; 
        ich sehe bei unseren Daten im Moment keinen Vorteil, ist aber auch nicht falsch. 
        Beide Stellen zu nehmen, wäre vielleicht auch nicht schlecht, um unterschiedliche Kunden zu bedienen
    -->
    <xsl:template mode="Gruppe" match="mpx:geogrBezug[@bezeichnung eq 'Kultur' 
        or @bezeichnung eq 'Ethnie'
        or @bezeichnung eq 'Sprachgruppe']">
        <lido:eventActor>
            <lido:displayActorInRole>
                <xsl:value-of select="."/>
                <xsl:text> (Herstellende </xsl:text>
                    <xsl:value-of select="@bezeichnung"/>
                <xsl:text>)</xsl:text>
            </lido:displayActorInRole>
            <lido:actorInRole>
                <lido:actor lido:type="group of persons">
                    <lido:nameActorSet>
                        <lido:appellationValue lido:pref="preferred">
                            <xsl:value-of select="mpx:geogrBezug[@bezeichnung eq 'Kultur']"/>
                        </lido:appellationValue>
                    </lido:nameActorSet>
                </lido:actor>
                <lido:roleActor>
                    <lido:term lido:addedSearchTerm="no">
                        <xsl:text>Herstellende </xsl:text>
                        <xsl:value-of select="@bezeichnung"/>
                    </lido:term>
                </lido:roleActor>
            </lido:actorInRole>
        </lido:eventActor>
    </xsl:template>

    <xsl:template mode="Ort" match="mpx:geogrBezug[@bezeichnung != 'Kultur' 
        or @bezeichnung != 'Ethnie'
        or @bezeichnung != 'Sprachgruppe']">
        <xsl:message>+++++++EVENT PLACE+++++++
            <xsl:value-of select="../@objId"/>
            <xsl:text>+++++++++++++</xsl:text>
        </xsl:message>
        <lido:eventPlace>
            <xsl:if test="@bezeichnung">
                <xsl:attribute name="lido:type">
                    <xsl:value-of select="@bezeichnung"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="lido:sortorder">
                <xsl:value-of select="@sort"/>
            </xsl:attribute>
            <!-- use displayPlace for rst -->
            <lido:displayPlace>
                <xsl:attribute name="xml:lang">de</xsl:attribute>
                <xsl:attribute name="lido:encodinganalog">mpx:geogrBezug</xsl:attribute>
                <xsl:value-of select="."/>
                <xsl:if test="@art">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@art"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </lido:displayPlace>
            <lido:displayPlace>
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:attribute name="lido:encodinganalog">mpxvoc</xsl:attribute>
                    <xsl:value-of select="."/>
                <xsl:if test="@art">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@art"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </lido:displayPlace>
            <!-- eigentlich haben wir nur displayPlace; 
            place is sort of fake since no thesaurus -->
            <lido:place>
                <xsl:choose>
                    <xsl:when test="@bezeichnung = 'Atoll'
                        or @bezeichnung = 'Bach'
                        or @bezeichnung = 'Bach/Zufluss'
                        or @bezeichnung = 'Berg'
                        or @bezeichnung = 'Bucht'
                        or @bezeichnung = 'Fluss'
                        or @bezeichnung = 'Fluss, Bucht und Dorf'
                        or @bezeichnung = 'Flussmündung'
                        or @bezeichnung = 'Gebirge'
                        or @bezeichnung = 'Hafen'
                        or @bezeichnung = 'Halbinsel'
                        or @bezeichnung = 'Insel'
                        or @bezeichnung = 'Insel/Region'
                        or @bezeichnung = 'Inselgruppe'
                        or @bezeichnung = 'Kap'
                        or @bezeichnung = 'Kontinent'
                        or @bezeichnung = 'Kontintentteil'
                        or @bezeichnung = 'Küste'
                        or @bezeichnung = 'Meerenge'
                        or @bezeichnung = 'Nebenfluss'
                        or @bezeichnung = 'See/Gebiet'
                        or @bezeichnung = 'Tal'">
                        <xsl:attribute name="lido:geographicalEntity">
                            <xsl:value-of select="@bezeichnung"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="lido:politicalEntity">
                            <xsl:value-of select="@bezeichnung"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                <lido:namePlaceSet>
                    <lido:appellationValue>
                        <xsl:value-of select="."/>
                    </lido:appellationValue>
                </lido:namePlaceSet>
            </lido:place>
        </lido:eventPlace>
    </xsl:template>

    <xsl:template match="mpx:materialTechnik[@art eq 'Ausgabe']">
        <lido:displayMaterialsTech>
                <xsl:value-of select="."/>
        </lido:displayMaterialsTech>
    </xsl:template>

    <xsl:template match="mpx:materialTechnik[@art ne 'Ausgabe']">
        <lido:termMaterialsTech lido:type="Material">
            <lido:term>
                <xsl:value-of select="."/>
            </lido:term>
        </lido:termMaterialsTech>
    </xsl:template>
</xsl:stylesheet>