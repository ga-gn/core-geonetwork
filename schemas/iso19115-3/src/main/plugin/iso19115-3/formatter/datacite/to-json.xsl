<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:util="java:org.fao.geonet.util.XslUtil"
    xpath-default-namespace="http://www.isotc211.org/2005/gmd"
    xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
    xmlns:schema-org-fn="http://geonetwork-opensource.org/xsl/functions/schema-org"
    xmlns:gn="http://www.fao.org/geonetwork" version="2.0"
    extension-element-prefixes="saxon" exclude-result-prefixes="#all">
    
    
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes" />
    
    <xsl:param name="doiPrefix" select="''" />
    <xsl:param name="defaultDoiPrefix" select="'https://dx.doi.org'" />
    <xsl:param name="url" select="''" />
    <xsl:param name="doiProtocolRegex" select="'(DOI|WWW:LINK-1.0-http--metadata-URL)'" />
    
    <xsl:variable name="metadata" select="//mdb:MD_Metadata" />
    <xsl:variable name="eCatId" select="//mdb:MD_Metadata/mdb:alternativeMetadataReference/*/cit:identifier/*/mcc:code/*/text()" />
    <xsl:variable name="doi" select="concat($doiPrefix, '/', $eCatId)" />
    <!-- TODO: Convert language code eng > en_US ? -->
    <xsl:variable name="metadataLanguage" select="//mdb:MD_Metadata/mdb:defaultLocale/*/lan:language/*/@codeListValue" />
    
    
    <xsl:variable name="authorRoles" select="'author', 'coAuthor'" />
    <xsl:variable name="pocRoles" select="'pointOfContact'" />
    <xsl:variable name="otherRoles" select="'custodian','publisher'" />
    
    <xsl:variable name="authors" select="/mdb:MD_Metadata/mdb:identificationInfo/*/mri:citation/*/cit:citedResponsibleParty/*/cit:party/cit:CI_Individual[../parent::cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = ($authorRoles)]]"/>
    <xsl:variable name="pocs" select="/mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/cit:CI_Individual[../parent::cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = ($pocRoles)]]"/>
    <xsl:variable name="others" select="/mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/cit:CI_Individual[../parent::cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = ($otherRoles)]]"/>
    
    <xsl:variable name="dateMapping">
        <entry key="creation">Created</entry>
        <entry key="revision">Updated</entry>
        <!--<entry key="publication"></entry> is in publicationYear -->
    </xsl:variable>

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


    <xsl:variable name="resourceScopeCode" select="//mdb:metadataScope/*/mdb:resourceScope/*/@codeListValue"/>
    <xsl:variable name="key" select="$resourceScopeCode"/>
    <xsl:variable name="resourceTypeGeneral" select="$scopeMapping//*[@key = $key]/text()"/>
    
    <xsl:template match="mdb:MD_Metadata">
        {
        "data": {
        "type": "dois",
        "attributes": {
        "id": "<xsl:value-of select="concat($defaultDoiPrefix, '/', $doi)" />",
        "doi": "<xsl:value-of select="$doi" />",
        "url": "<xsl:value-of select="$url" />",
        "state": "findable",
        "event": "publish",
		"types": {
        "resourceTypeGeneral": "<xsl:value-of select="$resourceTypeGeneral" />"
        },
        "creators": [
        
        <xsl:choose>
            <xsl:when test="count($authors) > 0">
                <xsl:for-each select="$authors">
                    {
                    <xsl:variable name="name" select="cit:name/*/text()" />
                    <xsl:call-template name="creator">
                        <xsl:with-param name="name" select="$name" />
                    </xsl:call-template>
                    }
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="count($pocs) > 0">
                <xsl:for-each select="$pocs">
                    {
                    <xsl:variable name="name" select="cit:name/*/text()" />
                    <xsl:call-template name="creator">
                        <xsl:with-param name="name" select="$name" />
                    </xsl:call-template>
                    }
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$others"> 
                    { 
                    <xsl:variable name="name" select="cit:name/*/text()"/>
                    <xsl:call-template name="creator">
                        <xsl:with-param name="name" select="$name"/>
                    </xsl:call-template> 
                    } 
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        ],
        "titles": [
        <xsl:for-each select="mdb:identificationInfo/*/mri:citation/*/cit:title">
            {
            "lang": "en",
            <xsl:if test="../cit:alternateTitle">
            "titleType":"<xsl:value-of select="../cit:alternateTitle/gco:CharacterString"/>",   
            </xsl:if>
            "title": "<xsl:value-of select="gco:CharacterString" />"
            }
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ],
        <xsl:for-each select="mdb:identificationInfo/*/mri:citation/*/cit:citedResponsibleParty/*/cit:party/cit:CI_Organisation[../parent::cit:CI_Responsibility[cit:role/*/@codeListValue = 'publisher']]">
            <xsl:if test="position() = 1">
            "publisher":"<xsl:value-of select="cit:name/gco:CharacterString" />",
            </xsl:if>
        </xsl:for-each>
        "subjects": [
        <xsl:if test="exists(mdb:identificationInfo/*/mri:descriptiveKeywords[1])">
            <xsl:for-each select="mdb:identificationInfo/*/mri:descriptiveKeywords/*/mri:keyword">
                {
                <xsl:variable name="thesaurusTitle" select="../mri:thesaurusName/*/cit:title" />
                "subject":"<xsl:value-of select="gco:CharacterString" />",
                <xsl:if test="gcx:Anchor/@xlink:href">
                    "valueUri": "<xsl:value-of select="gcx:Anchor/@xlink:href"/>",
                </xsl:if>
                <xsl:if test="$thesaurusTitle/gcx:Anchor/@xlink:href">
                    "schemeURI": "<xsl:value-of select="$thesaurusTitle/gcx:Anchor/@xlink:href"/>",
                </xsl:if>
                "subjectScheme": "<xsl:value-of select="normalize-space($thesaurusTitle/(gco:CharacterString | gcx:Anchor)/text()[. != ''])" />"
                }
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
        </xsl:if>
        ],
        "dates": [
        <xsl:for-each select="mdb:identificationInfo/*/mri:citation/*/cit:date/*[cit:dateType/*/@codeListValue = $dateMapping/entry/@key]">
            <xsl:variable name="key" select="cit:dateType/*/@codeListValue" />
            {
            "date": "<xsl:value-of select="cit:date/*/text()" />",
            "dateType": "<xsl:value-of select="$dateMapping//*[@key = $key]/text()" />"
            }
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ],
        <xsl:variable name="publicationYear" select="mdb:identificationInfo/*/mri:citation/*/cit:date/*[cit:dateType/*/@codeListValue = 'publication']/cit:date/substring(*, 1, 4)" />
        <xsl:if test="exists($publicationYear)">
            "publicationYear": "<xsl:value-of select="$publicationYear" />",    
        </xsl:if>
        "rightsList": [
        <xsl:for-each select="mdb:identificationInfo/*/mri:resourceConstraints/*">
            {
            <xsl:variable name="righturi" select="mco:reference/*/cit:onlineResource/*/cit:linkage/gco:CharacterString" />
            "rights":" <xsl:value-of select="mco:reference/*/cit:title/gco:CharacterString" />",
            "rightsUri": "<xsl:value-of select="$righturi" />"
            }
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ],
        "descriptions": [
        
        <xsl:for-each select="mdb:identificationInfo/*/mri:abstract">
            {
            "lang": "en",
            "description": "<xsl:value-of select="gco:CharacterString" />",
            "descriptionType": "Abstract"
            }
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ],
        "geoLocations": [
            <xsl:for-each select="mdb:identificationInfo/*/mri:extent/*/gex:geographicElement/gex:EX_GeographicBoundingBox">
                {
                "geoLocationBox" : {
                "westBoundLongitude":"<xsl:value-of select="gex:westBoundLongitude/*/text()" />",
                "eastBoundLongitude": "<xsl:value-of select="gex:eastBoundLongitude/*/text()" />",
                "southBoundLatitude":"<xsl:value-of select="gex:southBoundLatitude/*/text()" />",
                "northBoundLatitude":"<xsl:value-of select="gex:northBoundLatitude/*/text()" />"
                }
                }
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
        ]}
        }
        }
    </xsl:template>
    
    
    <xsl:template name="creator">
        <xsl:param name="name" />
        
        "name" : "<xsl:value-of select="$name" />",
        "nameType":"Personal",
        "givenName": "<xsl:value-of select="substring-before($name, ',')" />",
        "familyName": "<xsl:value-of select="normalize-space(substring-after($name, ','))" />",
        "affiliation": [{
        "name": "<xsl:value-of select="$name" />"
        }]
        
    </xsl:template>
    
</xsl:stylesheet>
