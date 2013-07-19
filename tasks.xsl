<?xml version="1.0" encoding="utf-8" ?>
<!--
  - This file is public domain.  Do whatever you like with it.
 -->
<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" media-type="application/xhtml+xml" encoding="utf-8" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:value-of select="tasks/@name"/></title>
        <link rel="stylesheet" type="text/css" href="tasks.css" />
        <script language="javascript" type="text/javascript">
          function showOverlay(id) {
            var overlay = document.getElementById(id);
            overlay.style.display = 'block';
          }
        </script>
      </head>
      <body>
        <h1><xsl:value-of select="tasks/@name"/></h1>
        <!-- emit overlays for task details -->
        <xsl:apply-templates select="tasks/category/task" mode="detail"/>

        <!-- emit main body -->
        <xsl:apply-templates select="tasks/category"/>
      </body>
    </html>
  </xsl:template>
  <xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

  <!--
    - Emit an overlay containing the full details of a task.
   -->
  <xsl:template match="task" mode="detail">
    <div class="overlay" onclick="this.style.display = 'none';">
      <xsl:attribute name="id"><xsl:value-of select="@name"/>:info</xsl:attribute>
      <div>
        <h2><xsl:value-of select="../@name"/> » <xsl:value-of select="@name"/></h2>
        <div><b>Description:</b>
          <xsl:choose>
            <xsl:when test="contains(., '&#xA;&#xA;')">
              <p><xsl:value-of select="substring-before(., '&#xA;&#xA;')"/></p>
              <p><xsl:value-of select="substring-after(., '&#xA;&#xA;')"/></p>
            </xsl:when>
            <xsl:otherwise>
              <p><xsl:copy-of select="."/></p>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <div><b>See specification:</b><p><xsl:value-of select="@specref"/></p></div>
      </div>
    </div>
  </xsl:template>

  <!--
    - Emit a category overview, containing a table of all subtasks.
   -->
  <xsl:template match="category">
    <h2><xsl:value-of select="@name"/></h2>
    <div class="table">
      <div>
        <span>Task Name</span>
        <span>Description</span>
        <span>Piglit</span>
        <span>Mesa</span>
      </div>
      <xsl:apply-templates select="task" mode="table"/>
    </div>
  </xsl:template>

  <xsl:template name="statuscolumn">
    <xsl:param name="attr"/>
    <span>
      <xsl:choose>
        <xsl:when test="$attr = 'done'">
          <xsl:attribute name="class">done</xsl:attribute>&#10003;
        </xsl:when>
        <xsl:when test="$attr = 'no'">
          <xsl:attribute name="class">missing</xsl:attribute>&#10007;
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$attr"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!--
    - Emit a table row for a task.
   -->
  <xsl:template match="task" mode="table">
    <a>
      <xsl:attribute name="href">
        javascript:showOverlay('<xsl:value-of select="@name"/>:info')
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@mesa and @piglit = 'done'">
          <xsl:attribute name="class">done</xsl:attribute>
        </xsl:when>
        <xsl:when test="@mesa or @piglit">
          <xsl:attribute name="class">partial</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <span>
        <xsl:value-of select="@name"/>
      </span>
      <span>
        <!--
          - Display a short description: text before two consecutive newlines.
          - This is similar to how git commit messages work.
         -->
        <xsl:choose>
          <xsl:when test="contains(., '&#xA;&#xA;')">
            <xsl:value-of select="substring-before(., '&#xA;&#xA;')"/> ... &#9656;
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:call-template name="statuscolumn">
        <xsl:with-param name="attr" select="@piglit"/>
      </xsl:call-template>
      <xsl:call-template name="statuscolumn">
        <xsl:with-param name="attr" select="@mesa"/>
      </xsl:call-template>
    </a>
  </xsl:template>
</xsl:stylesheet>
