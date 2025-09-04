# SIF

SIF is the **Schools Interoperability Framework** *(or sometimes Systems Interoperability Framework in the UK)*.

SIF is an industry-standard specification, for XML messages, and associated Service-Oriented Architecture (SOA), to share data relevant to primary and secondary education *(Kindergarten to Year 12 in Australia)*.

SIF specifications exist in four separate regional flavours for [Australia (AU)](http://specification.sifassociation.org/Implementation/AU/3.6.3/), [New Zealand (NZ)](http://specification.sifassociation.org/Implementation/NZ/3.2/), [North America (NA)](http://specification.sifassociation.org/Implementation/NA/4.3/), and the [United Kingdom (UK)](http://specification.sifassociation.org/Implementation/UK/2.0/html/).

All four regional SIF Specifications are owned and managed by the [Access 4 Learning Community](https://a4l.org/about-us/) *(A4L, founded in 1997 as the SIF Association)*, and in Australia, A4L works closely with the [National Schools Interoperability Program (NSIP), part of Education Services Australia (ESA)](https://www.nsip.edu.au/about/).

More history and context is available on [Wikipedia](https://en.wikipedia.org/wiki/Schools_Interoperability_Framework).

# Data models

## CEDS in North America

In North America, SIF has been harmonised with the Common Education Data Standards (CEDS) Data Model ([homepage](https://ceds.ed.gov/dataModel.aspx), [Wikipedia](https://en.wikipedia.org/wiki/Common_Education_Data_Standards), [Github](https://github.com/CEDStandards/CEDS-Data-Warehouse), [MS SQL DDL](https://github.com/CEDStandards/CEDS-Data-Warehouse/tree/master/src/ddl)) since SIF v3.0.

The CEDS Data Model is a star schema data warehouse with full coverage of and compatibility with the SIF specification.

## This project in Australia

In Australia, no CEDS-style equivalent relational data model exists, and AU SIF is sufficiently different from NA SIF, that CEDS cannot be directly reused in Australia.

This project takes the [AU SIF specification v3.6.3](http://specification.sifassociation.org/Implementation/AU/3.6.3/) and turns the XML tree structure into a relational data model, written in MS SQL DDL (see [/SIF_tables_creation/Drop-then-Create-SIF-tables.sql](https://github.com/phil-gg/AU-SIF-SQL/blob/main/SIF_tables_creation/Drop-then-Create-SIF-tables.sql)).

Tables are prefixed with: -
 - 'Dim' *(short for Dimension)*, or 'Bridge', or 'Fact', in accordance with the table's function if it was in a Kimball dimensional model, and

 - a digit, tracking the dependencies for creating foreign key constraints: -

    **(0\)**  zero for fixed reference information from the SIF specification only;

    **(1\)**  one for data ingested from systems of record *(with either no FK constraints or references to Dim0 only)*; and

    **(2\)**  two plus for tables with foreign key (FK) constraints *(each table with digit 'n' has a foreign key (FK) relation to a highest numbered table of 'n – 1')*.

However, in line with the source XML tree data structure (and unlike Kimball dimensional modelling standard practice), this data model is a snowflake schema, not a star schema.  This architectural decision lines up with the intended use of this project's output, as the companion database to a SIF message broker.  A snowflake schema exactly mapping to AU SIF v3.6.3 will be quicker to integrate with a SIF-compliant data broker, than a flattened star schema.

# eMinerva

eMinerva ([introduction](https://web.archive.org/web/20080721004425/http://www.mxl.com/downloads/Schools_product_sheet.pdf), [solution overview](https://web.archive.org/web/20080721004537/http://www.mxl.com/downloads/Schools_Solution_overview.pdf), [student portal](https://web.archive.org/web/20080720032125/http://www.mxl.com/publicsite/default.aspx?sectionid=179)) is a student information management system, built on the ASP.NET framework, with a Microsoft SQL Server data layer.  It was developed by MXL Consolidated Pty Ltd (ASN.MXL, founded 2001).

Large users of eMinerva include(d) Brisbane Catholic Education, and Department for Education Tasmania.  eMinerva is/was also one of seven [government accredited student management software systems in New Zealand](https://www.beehive.govt.nz/release/schools-get-choice-accredited-student-management-software).

MXL went into administration in 2010, and was bought by UXC Limited (ASX.UXC).  UXC's Eclipse business unit also integrated eMinerva with Microsoft Dynamics and sold it as EduPoint.  Computer Sciences Corporation (CSC) then bought UXC in a deal that closed in 2016.  CSC in turn merged with HP Enterprise in 2017 to create DXC Technology.

Therefore, the UXC Eclipse business unit still operates eMinerva today, as a wholly owned subsidiary of DXC.

Entellect Limited (ASX.ESN, two 'L's and not related to Entelect - one 'L' - a private entity headquartered in South Africa), was the parent company for MXL before administration in 2010, has no interest in eMinerva since 2010, and is now Kneomedia Ltd (ASX:KNM), developer of the unrelated KneoWorld education software.

## This project's relationship with eMinerva

This project provides some initial mappings of eMinerva data into the target SIF data, both as [select only queries](https://github.com/phil-gg/AU-SIF-SQL/tree/main/SIF_select_only), and as [inserts into the target data model](https://github.com/phil-gg/AU-SIF-SQL/tree/main/SIF_tables_data_insert).
