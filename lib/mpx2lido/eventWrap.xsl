<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8"
        indent="yes" />
    <xsl:strip-space elements="*" />

    <xsl:template name="eventWrap">
        <lido:eventWrap>
            <xsl:call-template name="Herstellung"/>
            <xsl:call-template name="Erwerb"/>
            <xsl:if test="mpx:personenKörperschaften[@funktion eq 'Sammler']">
                <xsl:call-template name="Sammeln"/>
            </xsl:if>
        </lido:eventWrap>
    </xsl:template>
    

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
                <xsl:apply-templates select="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']"/>
                <!-- Todo: There could be a PK@Hersteller -->

                <!-- lido: eventDate 
                SPEC: repeated displayDates only for language variants; 
                according to spec event dates cannot be repeated. AKu often 
                has multiple dates representing multiple estimates.-->

                <xsl:apply-templates select="mpx:datierung[min(@sort)][1]"/>

                <!-- lido: eventPlace -->
                <xsl:apply-templates select="mpx:geogrBezug[@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie']"/>

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
    <xsl:template match="mpx:geogrBezug[@bezeichnung eq 'Kultur' or @bezeichnung eq 'Ethnie']">
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


    <xsl:template match="mpx:geogrBezug[@bezeichnung ne 'Kultur' and @bezeichnung ne 'Ethnie']">
        <lido:eventPlace>
            <xsl:attribute name="lido:sortorder">
                <xsl:value-of select="@sort"/>
            </xsl:attribute>
            <lido:displayPlace>
                <xsl:value-of select="."/>
                <xsl:if test="@bezeichnung">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@bezeichnung"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </lido:displayPlace>
            <lido:place>
                <xsl:attribute name="lido:geographicalEntity">
                    <xsl:value-of select="@bezeichnung"/>
                </xsl:attribute>
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



    <!-- m3 rst: Neuer Event aus Ewerbsinformationen. -->
    <xsl:template name="Erwerb">
        <lido:eventSet>
            <lido:displayEvent xml:lang="de">Erwerb</lido:displayEvent>
            <lido:event>
                <lido:eventType>
                    <lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00001</lido:conceptID>
                    <lido:term xml:lang="de">Erwerb</lido:term>
                </lido:eventType>

                <!-- lido:eventActor -->
                <xsl:apply-templates select="mpx:erwerbungVon"/>

                <!-- lido:eventDate -->
                <xsl:apply-templates select="mpx:erwerbDatum"/>

                <!-- lido:eventMethod (m3: neuer Platz für Erwerbungsart nach Empfehlung FvH)-->
                <xsl:apply-templates select="mpx:erwerbungsart"/>
            </lido:event>
        </lido:eventSet>
    </xsl:template>


    <xsl:template match="mpx:erwerbDatum">
        <lido:eventDate>
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
            <lido:date>
                <lido:earliestDate>
                    <xsl:value-of select="."/>
                </lido:earliestDate>
                <lido:latestDate>
                    <xsl:value-of select="."/>
                </lido:latestDate>
            </lido:date>
        </lido:eventDate>
    </xsl:template>


    <xsl:template match="mpx:erwerbungVon">
        <lido:eventActor>
            <lido:displayActorInRole>
                <xsl:value-of select="."/>
                <xsl:text> (Veräußerer)</xsl:text>
                <!-- todo: PK(Veräußerer) -->
            </lido:displayActorInRole>
            <lido:actorInRole>
                <!-- todo -->
                <lido:actor lido:type="Person">
                    <!-- kein ID an dieser Stelle in M+ vorhanden (Register Erwerb); möglicherweise in RIA-->
                    <lido:nameActorSet>
                        <lido:appellationValue>
                            <xsl:value-of select="."/>
                        </lido:appellationValue>
                    </lido:nameActorSet>
                </lido:actor>
                <lido:roleActor>
                    <lido:term lido:addedSearchTerm="no">Veräußerer</lido:term>
                </lido:roleActor>
            </lido:actorInRole>
        </lido:eventActor>
    </xsl:template>


    <xsl:template match="mpx:erwerbungsart">
        <lido:eventMethod>
            <lido:term>Ankauf</lido:term>
        </lido:eventMethod>
    </xsl:template>



    <xsl:template name="Sammeln">
        <lido:eventSet>
            <lido:displayEvent>Sammeltätigkeit</lido:displayEvent>
            <lido:event>
                <lido:eventType>
                    <lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00010</lido:conceptID>
                    <lido:term>Sammeltätigkeit</lido:term>
                </lido:eventType>
                <lido:eventActor>
                    <lido:displayActorInRole>
                        <xsl:value-of select="mpx:personenKörperschaften[@funktion eq 'Sammler']"/>
                        <xsl:text> (Sammler)</xsl:text>
                    </lido:displayActorInRole>
                    <lido:actorInRole>
                        <lido:actor lido:type="Person">
                            <!-- I don't have the kueId currently
                                 lido:actorID lido:type="local" lido:source="Kue.Id.">2297</lido:actorID> 
                                 not necessary for RST
                            -->
                            <lido:nameActorSet>
                                <lido:appellationValue lido:pref="preferred" lido:label="Nachname, Vorname">
                                    <xsl:value-of select="mpx:personenKörperschaften[@funktion eq 'Sammler']"/>
                                </lido:appellationValue>
                            </lido:nameActorSet>
                            <!-- not necessary for RST
                                lido:vitalDatesActor />
                                lido:genderActor  -->
                        </lido:actor>
                        <lido:roleActor>
                            <lido:term lido:addedSearchTerm="no">Sammler</lido:term>
                        </lido:roleActor>
                    </lido:actorInRole>
                </lido:eventActor>
            </lido:event>
        </lido:eventSet>
    </xsl:template>
    
</xsl:stylesheet>