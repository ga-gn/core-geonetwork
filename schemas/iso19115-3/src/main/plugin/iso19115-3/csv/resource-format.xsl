<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:util="java:java.util.UUID"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">
    
    <xsl:param name="title" select="''"/>
    <xsl:param name="name" select="''"/>
    <xsl:param name="linkage" select="''"/>
    <xsl:param name="description" select="''"/>
    <xsl:param name="protocol" select="'FILE:DATA-DIRECTORY'"/>
    <xsl:param name="function" select="'offlineAccess'"/>
    
    
    <xsl:template match="/mrd:MD_Format">
        <xsl:copy>
            <mrd:formatSpecificationCitation>
                <cit:CI_Citation>
                    <cit:title>
                        <gco:CharacterString><xsl:value-of select="$title"/></gco:CharacterString>
                    </cit:title>
                    <cit:onlineResource>
                        <cit:CI_OnlineResource>
                            <cit:linkage>
                                <gco:CharacterString><xsl:value-of select="$linkage"/></gco:CharacterString>
                            </cit:linkage>
                            <cit:protocol>
                                <gco:CharacterString xsi:type="gco:CodeType" 
                                    codeSpace="http://pid.geoscience.gov.au/def/schema/ga/ISO19115-3-2016/codelist/ga_profile_codelists.xml#gapCI_ProtocolTypeCode"><xsl:value-of select="$protocol"/></gco:CharacterString>
                            </cit:protocol>
                            <cit:name>
                                <gco:CharacterString><xsl:value-of select="$name"/></gco:CharacterString>
                            </cit:name>
                            <cit:description>
                                <gco:CharacterString><xsl:value-of select="$description"/></gco:CharacterString>
                            </cit:description>
                            <cit:function>
                                <cit:CI_OnLineFunctionCode codeList="codeListLocation#CI_OnLineFunctionCode" codeListValue="{$function}"/>
                            </cit:function>
                        </cit:CI_OnlineResource>
                    </cit:onlineResource>
                </cit:CI_Citation>
            </mrd:formatSpecificationCitation>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>