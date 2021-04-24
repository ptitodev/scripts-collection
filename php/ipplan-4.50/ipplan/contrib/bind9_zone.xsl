<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="zone">$ORIGIN <xsl:value-of select="./@domain"/>.

<xsl:apply-templates select="soa"/>
<xsl:apply-templates select="record"/>
</xsl:template>


<xsl:template match="soa">
$TTL <xsl:value-of select="@refresh"/>
@	IN	SOA	<xsl:value-of select="/zone/@domain"/>.	<xsl:value-of select="@email"/>. (
			<xsl:value-of select="@serialdate"/><xsl:value-of select="@serialnum"/> ; serial
			<xsl:value-of select="@ttl"/>      ; refresh
			<xsl:value-of select="@retry"/>       ; retry
			<xsl:value-of select="@expire"/>     ; expire
			<xsl:value-of select="@minimumttl"/> )    ; minimum TTL
</xsl:template>

<xsl:template match="record">
<xsl:for-each select="NS" xml:space="preserve">
	IN	NS	<xsl:value-of select="iphostname"/>.</xsl:for-each>

<xsl:for-each select="A" xml:space="preserve">
<xsl:value-of select="host"/>	IN	A	<xsl:value-of select="iphostname"/></xsl:for-each>

<xsl:for-each select="CNAME" xml:space="preserve">
<xsl:value-of select="host"/>	IN	CNAME	<xsl:value-of select="iphostname"/></xsl:for-each>

<xsl:for-each select="MX" xml:space="preserve">
<xsl:value-of select="host"/>	IN	MX	<xsl:value-of select="preference"/> <xsl:value-of select="iphostname"/></xsl:for-each>

</xsl:template>

</xsl:stylesheet>

