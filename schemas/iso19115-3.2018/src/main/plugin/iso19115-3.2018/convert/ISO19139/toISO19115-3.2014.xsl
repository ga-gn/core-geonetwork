<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gsr="http://www.isotc211.org/2005/gsr"
                xmlns:gss="http://www.isotc211.org/2005/gss"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:srv2="http://standards.iso.org/iso/19115/-3/srv/2.1"
                xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
                xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/2.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/2.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gco2="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">
  <!--
  Conversion from ISO19115-3:2018 to ISO19115-3:2014
  -->
  <xsl:import href="utility/create19115-3.2014Namespaces.xsl"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="mdb:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/mdb/1.0">
      <xsl:if test="count(ancestor::*) = 0">
        <xsl:call-template name="add-iso19115-3.2014-namespaces"/>
      </xsl:if>
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="cit:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/cit/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="mds:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/mds/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="mrc:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/mrc/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="msr:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/msr/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="mrl:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/mrl/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="mac:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/mac/1.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="srv2:*" priority="200">
    <xsl:element name="{name()}" namespace="http://standards.iso.org/iso/19115/-3/srv/2.0">
      <xsl:apply-templates select="@*|*"/>
    </xsl:element>
  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
