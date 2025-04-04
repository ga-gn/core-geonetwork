<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->
<!-- Conversion from iso19115-3.2018 to Datacite
    See http://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf
    Mandatory elements / There is no check that those elements are present in the record
    ID Property Obligation
1 Identifier (with mandatory type sub-property) M
2 Creator (with optional given name, family name, name identifier and affiliation sub-properties) M
3 Title (with optional type sub-properties) M
4 Publisher M
5 PublicationYear M
10 ResourceType (with mandatory general type description subproperty) M
    The following elements are not mapped
    * alternateIdentifiers: Not sure if there is requirements for this
      <datacite:alternateIdentifiers>
        <datacite:alternateIdentifier alternateIdentifierType="URL">https://schema.datacite.org/meta/kernel-4.1/example/datacite-example-full-v4.1.xml</datacite:alternateIdentifier>
      </datacite:alternateIdentifiers>
    * relatedIdentifiers: Would make sense if target relation is also a DOI ?
      <datacite:relatedIdentifiers>
        <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="HasMetadata" relatedMetadataScheme="citeproc+json" schemeURI="https://github.com/citation-style-language/schema/raw/master/csl-data.json">https://data.datacite.org/application/citeproc+json/10.5072/example-full</datacite:relatedIdentifier>
        <datacite:relatedIdentifier relatedIdentifierType="arXiv" relationType="IsReviewedBy" resourceTypeGeneral="Text">arXiv:0706.0001</datacite:relatedIdentifier>
      </datacite:relatedIdentifiers>
    * sizes
      <datacite:sizes>
        <datacite:size>4 kB</datacite:size>
      </datacite:sizes>
    * fundingReferences
      <datacite:fundingReferences>
        <datacite:fundingReference>
          <datacite:funderName>National Science Foundation</datacite:funderName>
          <datacite:funderIdentifier funderIdentifierType="Crossref Funder ID">https://doi.org/10.13039/100000001</datacite:funderIdentifier>
          <datacite:awardNumber>CBET-106</datacite:awardNumber>
          <datacite:awardTitle>Full DataCite XML Example</datacite:awardTitle>
        </datacite:fundingReference>
      </datacite:fundingReferences>
     To retrieve a record:
     http://localhost:8080/geonetwork/srv/api/records/ff8d8cd6-c753-4581-99a3-af23fe4c996b/formatters/datacite?output=xml
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
  xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/1.0"
  xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
  xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
  xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
  xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
  xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
  xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
  xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
  xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
  xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
  xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0"
  xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
  xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
  xmlns:saxon="http://saxon.sf.net/" xmlns:gn="http://www.fao.org/geonetwork"
  extension-element-prefixes="saxon" exclude-result-prefixes="#all">

  <xsl:output method="xml" indent="yes"/>

  <!-- Before attribution of a DOI the ISO19139 record does not contain yet
  the DOI value. It is built from the DOI prefix provided as parameter
  and the UUID of the record.
  If the DOI already exist in the record, this parameter is not set and the DOI
  is returned as datacite:identifier -->
  <xsl:param name="doiPrefix" select="''"/>
  <xsl:param name="defaultDoiPrefix" select="'http://dx.doi.org/'"/>
  <xsl:param name="doiProtocolRegex" select="'(DOI|WWW:LINK-1.0-http--metadata-URL)'"/>

  <xsl:variable name="metadata" select="//mdb:MD_Metadata"/>

  <!-- TODO: Convert language code eng > en_US ? -->
  <xsl:variable name="metadataLanguage"
    select="//mdb:MD_Metadata/mdb:defaultLocale/*/lan:language/*/@codeListValue"/>


  <xsl:template match="/">
    <datacite:resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.1/metadata.xsd">
      <xsl:apply-templates select="$metadata" mode="toDatacite"/>
    </datacite:resource>
  </xsl:template>

  <!--
  The Identifier is a unique string that identifies a resource. For software, determine whether the
  identifier is for a specific version of a piece of software, (per the Force11 Software
  Citation Principles13), or for all versions.
  -->
  <xsl:template mode="toDatacite"
    match="mdb:MD_Metadata/mdb:alternativeMetadataReference/*/cit:identifier/*/mcc:code/*/text()">
    <datacite:identifier identifierType="DOI">
      <!-- Return existing one -->
      <xsl:choose>
        <xsl:when test="$doiPrefix = ''">
          <xsl:variable name="doiFromMetadataLinkage"
            select="normalize-space(ancestor::mdb:MD_Metadata/mdb:alternativeMetadataReference/*/cit:identifier/*/mcc:code/gco:CharacterString[starts-with(., $defaultDoiPrefix) or ../../cit:function/*/@codeListValue = 'doi'])"/>
          <xsl:value-of select="$doiFromMetadataLinkage"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Build a new one -->
          <xsl:value-of select="concat($doiPrefix, '/', .)"/>
        </xsl:otherwise>
      </xsl:choose>
    </datacite:identifier>
  </xsl:template>


  <!--
    The general type of a resource
    Controlled List Values:
    Audiovisual
    Collection
    DataPaper
    Dataset
    Event
    Image
    InteractiveResource
    Model
    PhysicalObject
    Service
    Software
    Sound
    Text18
    Workflow
    Other
    See Appendix for definitions and
    examples.
  -->
  <xsl:variable name="scopeMapping">
    <entry key="attribute">Model</entry>
    <entry key="attributeType">Model</entry>
    <entry key="featureType">Model</entry>
    <entry key="propertyType">Model</entry>
    <entry key="model">Model</entry>
    <entry key="collectionHardware">Other</entry>
    <entry key="collectionSession">Dataset</entry>
    <entry key="dataset">Dataset</entry>
    <entry key="tile">Image</entry>
    <entry key="nonGeographicDataset">Dataset</entry>
    <entry key="dimensionGroup">Other</entry>
    <entry key="fieldSession">Event</entry>
    <entry key="feature">PhysicalObject</entry>
    <entry key="series">Dataset</entry>
    <entry key="service">Service</entry>
    <entry key="software">Software</entry>
    <entry key="document">Text</entry>
    <entry key="collection">Collection</entry>
  </xsl:variable>

  <xsl:template mode="toDatacite" match="mdb:metadataScope/*/mdb:resourceScope/*/@codeListValue">
    <xsl:variable name="key" select="."/>
    <xsl:variable name="type" select="concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
    <datacite:resourceType resourceTypeGeneral="{$scopeMapping//*[@key = $key]/text()}">
      <xsl:value-of select="$type"/>
    </datacite:resourceType>
  </xsl:template>

  <!--
   The main researchers involved in producing the data, or the authors of the publication, in 
   priority order. To supply multiple creators, repeat this property.
   -->
  <xsl:variable name="creatorRoles" select="'pointOfContact', 'custodian'"/>
  <xsl:variable name="authorRoles" select="'author', 'coAuthor'"/>

  <xsl:template mode="toDatacite" match="mdb:MD_Metadata/mdb:identificationInfo/*">

    <!-- The primary language of the resource. -->
    <xsl:if test="mri:defaultLocale[1]/*/lan:language/*/@codeListValue">
      <!-- TODO: Allowed values are taken from IETF BCP 47, ISO 639-1 language codes. Examples: en, de, fr -->
      <datacite:language>
        <xsl:value-of select="mri:defaultLocale[1]/*/lan:language/*/@codeListValue"/>
      </datacite:language>
    </xsl:if>

    <!-- A name or title by which a resource is known. May be the title of a dataset or the name of a piece of software. -->
    <datacite:titles>
      <xsl:for-each select="mri:citation/*/cit:title">
        <xsl:call-template name="toDataciteLocalized">
          <xsl:with-param name="template">
            <datacite:title/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="../cit:alternateTitle">
        <xsl:call-template name="toDataciteLocalized">
          <xsl:with-param name="template">
            <datacite:title titleType="AlternativeTitle"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </datacite:titles>

    <!-- All additional information that does not fit in any of the other categories. May be used for technical information. -->
    <xsl:for-each select="mri:abstract">
      <datacite:descriptions>
        <xsl:call-template name="toDataciteLocalized">
          <xsl:with-param name="template">
            <datacite:description descriptionType="Abstract"/>
          </xsl:with-param>
        </xsl:call-template>
      </datacite:descriptions>
    </xsl:for-each>


    <xsl:if test="exists(mri:extent/*/gex:geographicElement/gex:EX_GeographicBoundingBox[1])">
      <datacite:geoLocations>
        <xsl:for-each select="$metadata/mdb:identificationInfo//gex:EX_GeographicBoundingBox">
          <datacite:geoLocation>
            <!--TODO: <datacite:geoLocationPlace>Atlantic Ocean</datacite:geoLocationPlace>-->
            <datacite:geoLocationBox>
              <datacite:westBoundLongitude>
                <xsl:value-of select="gex:westBoundLongitude/*/text()"/>
              </datacite:westBoundLongitude>
              <datacite:eastBoundLongitude>
                <xsl:value-of select="gex:eastBoundLongitude/*/text()"/>
              </datacite:eastBoundLongitude>
              <datacite:southBoundLatitude>
                <xsl:value-of select="gex:southBoundLatitude/*/text()"/>
              </datacite:southBoundLatitude>
              <datacite:northBoundLatitude>
                <xsl:value-of select="gex:northBoundLatitude/*/text()"/>
              </datacite:northBoundLatitude>
            </datacite:geoLocationBox>
          </datacite:geoLocation>
        </xsl:for-each>
      </datacite:geoLocations>
    </xsl:if>


    <xsl:if test="exists(mri:descriptiveKeywords[1])">
      <datacite:subjects>
        <xsl:for-each select="$metadata//mri:keyword">
          <xsl:call-template name="toDataciteLocalized">
            <xsl:with-param name="template">
              <datacite:subject>
                <xsl:variable name="thesaurusTitle" select="../mri:thesaurusName/*/cit:title"/>
                <xsl:if test="$thesaurusTitle/gcx:Anchor/@xlink:href">
                  <xsl:attribute name="schemeURI" select="$thesaurusTitle/gcx:Anchor/@xlink:href"/>
                </xsl:if>
                <xsl:if test="$thesaurusTitle/*/text()">
                  <xsl:attribute name="subjectScheme"
                    select="normalize-space($thesaurusTitle/(gco:CharacterString | gcx:Anchor)/text()[. != ''])"
                  />
                </xsl:if>
                <xsl:if test="gcx:Anchor/@xlink:href">
                  <xsl:attribute name="valueUri" select="gcx:Anchor/@xlink:href"/>
                </xsl:if>
              </datacite:subject>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </datacite:subjects>
    </xsl:if>

    <datacite:creators>
      <!-- [cit:role/*/@codeListValue = $roles] TODO: Restrict on roles ?-->
      <xsl:for-each select="mri:pointOfContact/*">
        <xsl:if
          test="cit:role/*/@codeListValue = ($creatorRoles) and exists(cit:party/cit:CI_Individual)">
          <xsl:variable name="name" select="cit:party/cit:CI_Individual/cit:name/*/text()"/>
          <xsl:call-template name="creator">
            <xsl:with-param name="name" select="$name"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="mri:citation/*/cit:citedResponsibleParty/*">
        <xsl:if
          test="cit:role/*/@codeListValue = ($authorRoles) and exists(cit:party/cit:CI_Individual)">
          <xsl:variable name="name" select="cit:party/cit:CI_Individual/cit:name/*/text()"/>
          <xsl:call-template name="creator">
            <xsl:with-param name="name" select="$name"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </datacite:creators>

    <!--
      The name of the entity that holds, archives, publishes prints, distributes, releases, issues, or produces the
      resource. This property will be used to formulate the citation, so consider the prominence of
      the role. For software, use Publisher for the code repository. If there is an entity other than a code repository,
      that "holds, archives, publishes, prints, distributes, releases, issues, or produces" the code, use the property
      Contributor/contributorType/hostingInstitution for the code repository.
      eg.
      <datacite:publisher>DataCite</datacite:publisher>
      <datacite:publicationYear>2014</datacite:publicationYear>
      TODO: Define who is the publisher ? Only one allowed.
    -->

	<datacite:publisher>
      <xsl:for-each select="//cit:CI_Organisation[../parent::cit:CI_Responsibility[cit:role/*/@codeListValue = 'publisher']]">
        <xsl:if test="position() = 1">
          <xsl:value-of select="cit:name/gco:CharacterString"/>
        </xsl:if>
      </xsl:for-each>
    </datacite:publisher>
    
    <!--
    The year when the data was or will be made publicly available. In the case of resources such as software or
    dynamic data where there may be multiple releases in one year, include the Date/dateType/ dateInformation property 
    and sub-properties to provide more information about the publication or release date details
    -->
    <xsl:variable name="publicationDate"
      select="mri:citation/*/cit:date/*[cit:dateType/*/@codeListValue = 'publication']/cit:date/substring(*, 1, 4)"/>
    <xsl:if test="$publicationDate != ''">
      <datacite:publicationYear>
        <xsl:value-of select="$publicationDate"/>
      </datacite:publicationYear>
    </xsl:if>


    <!--
      Controlled List Values:
      Accepted
      Available
      Copyrighted
      Collected
      Created
      Issued
      Submitted
      Updated
      Valid
      Other
    -->
    <xsl:variable name="dateMapping">
      <entry key="creation">Created</entry>
      <entry key="revision">Updated</entry>
      <!--<entry key="publication"></entry> is in publicationYear -->
    </xsl:variable>

    <datacite:dates>
      <xsl:for-each
        select="mri:citation/*/cit:date/*[cit:dateType/*/@codeListValue = $dateMapping/entry/@key]">
        <xsl:variable name="key" select="cit:dateType/*/@codeListValue"/>
        <datacite:date dateType="{$dateMapping//*[@key = $key]/text()}">
          <xsl:value-of select="cit:date/*/text()"/>
        </datacite:date>
      </xsl:for-each>
    </datacite:dates>

    <!--
      Any rights information for this resource. The property may be repeated to record complex rights characteristics.
      <datacite:rightsList>
        <datacite:rights xml:lang="en-US" rightsURI="http://creativecommons.org/publicdomain/zero/1.0/">CC0 1.0 Universal</datacite:rights>
      </datacite:rightsList>
      -->
    <datacite:rightsList>
      <xsl:for-each select="mri:resourceConstraints/*">
        <datacite:rights>
          <xsl:variable name="righturi"
            select="mco:reference/*/cit:onlineResource/*/cit:linkage/gco:CharacterString"/>
          <xsl:if test="exists($righturi)">
            <xsl:attribute name="rightsURI" select="$righturi"/>
          </xsl:if>
          <xsl:value-of select="mco:reference/*/cit:title/gco:CharacterString"/>
        </datacite:rights>
      </xsl:for-each>
    </datacite:rightsList>

  </xsl:template>


  <xsl:template name="creator">
    <xsl:param name="name"/>
    <datacite:creator>
      <!--  Expect the entry point to be CI_Organisation The full name of the creator. -->

      <datacite:creatorName nameType="Personal">
        <xsl:value-of select="$name"/>
      </datacite:creatorName>
      <datacite:givenName>
        <xsl:value-of select="substring-before($name, ',')"/>
      </datacite:givenName>
      <datacite:familyName>
        <xsl:value-of select="normalize-space(substring-after($name, ','))"/>
      </datacite:familyName>
      <!-- <datacite:nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0001-5000-0007</datacite:nameIdentifier>
          -->
      <xsl:apply-templates mode="toDataciteLocalized" select="cit:party/*/cit:name">
        <xsl:with-param name="template">
          <datacite:affiliation/>
        </xsl:with-param>
      </xsl:apply-templates>
    </datacite:creator>

  </xsl:template>


  <!-- TODO: contributors The institution or person responsible for collecting, managing, distributing, or
  otherwise contributing to the development of the resource. To supply multiple contributors, repeat this property.
  For software, if there is an alternate entity that "holds, archives, publishes, prints, distributes, releases, 
  issues, or produces" the code, use the contributorType "hostingInstitution" for the code repository.
eg.
      <datacite:contributors>
        <datacite:contributor contributorType="ProjectLeader">
          <datacite:contributorName>Starr, Joan</datacite:contributorName>
          <datacite:givenName>Joan</datacite:givenName>
          <datacite:familyName>Starr</datacite:familyName>
          <datacite:nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0002-7285-027X</datacite:nameIdentifier>
          <datacite:affiliation>California Digital Library</datacite:affiliation>
        </datacite:contributor>
      </datacite:contributors>
   If Contributor is used, then contributorType is mandatory.
    Controlled List Values:
    ContactPerson
    DataCollector
    DataCurator
    DataManager
    Distributor
    Editor
    HostingInstitution
    Producer
    ProjectLeader
    ProjectManager
    ProjectMember
    RegistrationAgency
    RegistrationAuthority
    RelatedPerson
    Researcher
    ResearchGroup
    RightsHolder
    Sponsor
    Supervisor
    WorkPackageLeader
    Other
  -->

  <!--
  Technical format of the resource.
      <datacite:formats>
        <datacite:format>application/xml</datacite:format>
      </datacite:formats>
      -->
  <xsl:template mode="toDatacite" match="mdb:MD_Metadata/mdb:distributionInfo/*">
    <datacite:formats>
      <xsl:for-each select="mrd:distributor/*/mrd:distributorTransferOptions/*">
        <datacite:format>
          <xsl:value-of select="normalize-space(mrd:distributionFormat/*/mrd:formatSpecificationCitation/*/cit:title)"/>
        </datacite:format>
      </xsl:for-each>
    </datacite:formats>
  </xsl:template>


  <!--
  The version number of the resource.
      <datacite:version>4.1</datacite:version>
      -->
  <xsl:template mode="toDatacite" match="cit:edition">
    <datacite:version>
      <xsl:value-of select="gco:CharacterString"/>
    </datacite:version>
  </xsl:template>


  <!-- Convert a multi or monolingual element to a localized datacite element. -->
  <xsl:template name="toDataciteLocalized" mode="toDataciteLocalized" match="*">
    <xsl:param name="template" as="node()"/>
    <xsl:choose>
      <xsl:when test="lan:PT_FreeText">
        <xsl:for-each select="lan:PT_FreeText/lan:textGroup/*">
          <xsl:variable name="languageId" select="@locale"/>
          <xsl:variable name="languageCode"
            select="$metadata/mdb:otherLocale/*[concat('#', @id) = $languageId]/lan:language/*/@codeListValue"/>
          <xsl:element name="{name($template/*)}">
            <xsl:attribute name="xml:lang" select="$languageCode"/>
            <xsl:copy-of select="$template/*/@*"/>
            <xsl:value-of select="."/>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{name($template/*)}">
          <xsl:attribute name="xml:lang" select="$metadataLanguage"/>
          <xsl:copy-of select="$template/*/@*"/>
          <xsl:value-of select="gco:CharacterString | gcx:Anchor"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--Traverse tree -->
  <xsl:template mode="toDatacite" match="@* | node()">
    <xsl:apply-templates mode="toDatacite" select="@* | node()"/>
  </xsl:template>
</xsl:stylesheet>
