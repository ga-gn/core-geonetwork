<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.1"
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
    xmlns:gn="http://www.fao.org/geonetwork"
    exclude-result-prefixes="#all">
    
    <xsl:param name="keyword"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*/mri:descriptiveKeywords[position() = last()]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
        <mri:descriptiveKeywords>
            <mri:MD_Keywords>
                <mri:keyword>
                    <gco:CharacterString>
                        <xsl:value-of select="$keyword"/>
                    </gco:CharacterString>
                </mri:keyword>
            </mri:MD_Keywords>
        </mri:descriptiveKeywords>
    </xsl:template>

</xsl:stylesheet>
