<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
				xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
				xmlns:tns="http://www.4d.com/namespace/default"
                exclude-result-prefixes="wsdl"				
                >
				
<xsl:output method="text" />

<xsl:param name="WSDL_URL" />
<xsl:param name="SOAP_METHOD" />
<xsl:param name="C_TEXT" />
<xsl:param name="ARRAY_TEXT" />

<xsl:template match="/">

<!-- read the first service name, A_WebService by default (usually 4D pulishes one service only) -->
<xsl:variable name="service-name" select="/wsdl:definitions/@name" />

<!-- the namespace url-->
<xsl:variable name="method-namespace-uri" select="/wsdl:definitions/@targetNamespace" />

<!-- the endpoint url-->
<xsl:variable name="application-url" select="/wsdl:definitions/wsdl:service[@name = $service-name]/wsdl:port/soap:address/@location" />

<!-- the list of input arguments ($1, $2, $3...) -->
<xsl:variable name="input" select="/wsdl:definitions[@name = $service-name]/wsdl:portType/wsdl:operation[@name = $SOAP_METHOD]/wsdl:input" />
<xsl:variable name="input-part-name" select="substring-after($input/@message, 'tns:')" />
<xsl:variable name="input-part" select="/wsdl:definitions[@name = $service-name]/wsdl:message[@name = $input-part-name]/wsdl:part" />

<!-- the return value ($0) and additional return values -->
<xsl:variable name="output" select="/wsdl:definitions[@name = $service-name]/wsdl:portType/wsdl:operation[@name = $SOAP_METHOD]/wsdl:output" />
<xsl:variable name="output-part-name" select="substring-after($output/@message, 'tns:')" />
<xsl:variable name="output-part" select="/wsdl:definitions[@name = $service-name]/wsdl:message[@name = $output-part-name]/wsdl:part" />

<xsl:if test="$output-part">
	<xsl:text>--values returned from 4D&#xD;&#xA;&#xD;&#xA;</xsl:text>
</xsl:if>

<xsl:for-each select="$output-part">

	<xsl:variable name="output-name" select="./@name" />
	<xsl:variable name="output-type" select="./@type" />

	<xsl:choose>

		<xsl:when test="$output-type = 'xsd:string'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to &quot;&quot;--</xsl:text><xsl:value-of select="$C_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>

		<xsl:when test="$output-type = 'tns:ArrayOfstring'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to {}--</xsl:text><xsl:value-of select="$ARRAY_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>
			
	</xsl:choose>
	
</xsl:for-each>

<xsl:text>&#xD;&#xA;</xsl:text>

<xsl:if test="$input-part">
	<xsl:text>--arguments to pass 4D&#xD;&#xA;&#xD;&#xA;</xsl:text>
</xsl:if>

<xsl:for-each select="$input-part">

	<xsl:variable name="input-name" select="./@name" />
	<xsl:variable name="input-type" select="./@type" />

	<xsl:choose>
	
		<xsl:when test="$input-type = 'xsd:string'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$input-name" />
		<xsl:text> to &quot;&quot;--</xsl:text><xsl:value-of select="$C_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>
	
		<xsl:when test="$input-type = 'tns:ArrayOfstring'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$input-name" />
		<xsl:text> to {}--</xsl:text><xsl:value-of select="$ARRAY_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>
			
	</xsl:choose>
	
</xsl:for-each>

<xsl:text>&#xD;&#xA;--call remote method&#xD;&#xA;</xsl:text>

<xsl:text>&#xD;&#xA;</xsl:text>

<xsl:text>tell application &quot;</xsl:text>
<xsl:value-of select="$application-url" />
<xsl:text>&quot;&#xD;&#xA;</xsl:text>

<!-- if there is a return value -->
<xsl:if test="$output-part">
<xsl:text>set FourD_soap_response to </xsl:text>
</xsl:if>

<xsl:text>call soap {method name:&quot;</xsl:text>
<xsl:value-of select="$SOAP_METHOD" />
<xsl:text>&quot;, </xsl:text>

<xsl:text>method namespace uri:&quot;</xsl:text>
<xsl:value-of select="$method-namespace-uri" />
<xsl:text>&quot;, </xsl:text>

<xsl:text>parameters:{</xsl:text>
<xsl:for-each select="$input-part">
<xsl:variable name="input-name" select="./@name" />
<xsl:variable name="input-type" select="./@type" />
<xsl:choose>

	<xsl:when test="$input-type = 'xsd:string'">
	<xsl:if test="position() != 1">
	<xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:text>|</xsl:text>
	<xsl:value-of select="$input-name" />
	<xsl:text>|:</xsl:text>
	<xsl:value-of select="$input-name" />
	<xsl:text> as string</xsl:text>
	</xsl:when>

	<xsl:when test="$input-type = 'tns:ArrayOfstring'">
	<xsl:if test="position() != 1">
	<xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:text>|</xsl:text>
	<xsl:value-of select="$input-name" />
	<xsl:text>|:</xsl:text>
	<xsl:value-of select="$input-name" />
	<xsl:text> as list</xsl:text>
	</xsl:when>

</xsl:choose>
</xsl:for-each>
<xsl:text>}, </xsl:text>

<xsl:text>SOAPAction:&quot;</xsl:text>
<xsl:value-of select="concat($service-name, '#', $SOAP_METHOD)" />
<xsl:text>&quot;}&#xD;&#xA;</xsl:text>
<xsl:text>end tell&#xD;&#xA;</xsl:text>
<xsl:text>&#xD;&#xA;</xsl:text>

<xsl:if test="$output-part">

<xsl:text>try&#xD;&#xA;</xsl:text>
<xsl:text>if class of FourD_soap_response is record then&#xD;&#xA;</xsl:text>

<!--multiple values in response-->

<xsl:for-each select="$output-part">

	<xsl:variable name="output-name" select="./@name" />
	<xsl:variable name="output-type" select="./@type" />

	<xsl:choose>

		<xsl:when test="$output-type = 'xsd:string'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to </xsl:text>
		<xsl:value-of select="$output-name" />	
		<xsl:text> of FourD_soap_response --</xsl:text><xsl:value-of select="$C_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>
	
		<xsl:when test="$output-type = 'tns:ArrayOfstring'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to </xsl:text>
		<xsl:value-of select="$output-name" />	
		<xsl:text> of FourD_soap_response --</xsl:text><xsl:value-of select="$ARRAY_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>	
	
	</xsl:choose>

</xsl:for-each>

<xsl:text>else if class of FourD_soap_response is text then&#xD;&#xA;</xsl:text>

	<xsl:variable name="output-name" select="$output-part[1]/@name" />
	<xsl:variable name="output-type" select="$output-part[1]/@type" />

	<xsl:choose>

		<xsl:when test="$output-type = 'xsd:string'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to </xsl:text>	
		<xsl:text>FourD_soap_response --</xsl:text><xsl:value-of select="$C_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>
	
		<xsl:when test="$output-type = 'tns:ArrayOfstring'">
		<xsl:text>set </xsl:text>
		<xsl:value-of select="$output-name" />
		<xsl:text> to </xsl:text>
		<xsl:text>FourD_soap_response --</xsl:text><xsl:value-of select="$ARRAY_TEXT" /><xsl:text>&#xD;&#xA;</xsl:text>	
		</xsl:when>	
	
	</xsl:choose>

<xsl:text>end if&#xD;&#xA;</xsl:text>
<xsl:text>end try&#xD;&#xA;</xsl:text>

</xsl:if>

</xsl:template>

</xsl:stylesheet>