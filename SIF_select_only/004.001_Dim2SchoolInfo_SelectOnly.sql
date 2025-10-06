SELECT c.Code
      ,c.Name
      ,c.AccreditedName
      ,c.CRICOSName
      ,t.Name AS CampusTypeName
      ,c.Location
      ,c.ABN
      ,c.Currency
      ,c.ProviderCode
      ,c.ProviderName
--      ,c.TrainingAuthorityID -- all null commented out
--      ,c.AVET_TrainOrgID -- all null commented out
--      ,c.AVET_TrainOrgName -- all null commented out
--      ,c.AVET_TrainOrgShName -- all null commented out
--      ,c.AVET_AddFirstLine -- all null commented out
--      ,c.AVET_AddSecondLine -- all null commented out
--      ,c.AVET_SubTownLoc -- all null commented out
--      ,c.AVET_PCode -- all null commented out
--      ,c.AVET_ContName -- all null commented out
--      ,c.AVET_PhNum -- all null commented out
--      ,c.AVET_FaxNum -- all null commented out
--      ,c.AVET_EmailAdd -- all null commented out
--      ,c.AVET_TrainTypeID -- all null commented out
--      ,c.AVET_State -- all null commented out
--      ,c.AVET_TrainAuthorityID -- all null commented out
--      ,c.AVET_TrainAuthorityName -- all null commented out
--      ,c.AVET_AuthAddFirstLine -- all null commented out
--      ,c.AVET_AuthAddSecondLine -- all null commented out
--      ,c.AVET_AuthPCode -- all null commented out
--      ,c.AVET_AuthState -- all null commented out
--      ,c.AVET_AuthContactNAme -- all null commented out
--      ,c.AVET_AuthTelephone -- all null commented out
--      ,c.AVET_AuthFacsimile -- all null commented out
--      ,c.AVET_AuthEmail -- all null commented out
--      ,c.AVET_AuthSubTownLoc -- all null commented out
      ,CASE WHEN LEFT(c.notes,9)='Maze Code'
            THEN RIGHT(c.notes,4)
            ELSE NULL END AS MazeCode
--      ,c.SchoolNum -- duplicate of Code commented out
--      ,c.DateLastIncRan -- all null commented out
--      ,c.DateNextRunOK -- all null commented out
--      ,c.IncYearMonths -- all zero commented out
--      ,c.WSDLLocation -- all null commented out
--      ,c.CertificateName -- all null commented out
--      ,c.CanSubmitElec -- all zero commented out
      ,c.Gender AS GenderCode
      ,c.EstDate
      ,c.ClosedDate
--      ,c.DataCompliant -- all zero commented out
      ,c.ABNBranchNo
      ,c.NSN
      ,c.NCN
      ,c.StateEduID
      ,c.AdminArea as AdminAreaCode
      ,c.ServiceArea as ServiceAreaCode
--      ,c.AccreditedType -- all empty string commented out
      ,c.GeoArea as GeoAreaCode
      ,c.SiteSize
      ,c.RPropDesc
      ,c.MapRef
      ,c.ChurchAffiliation
      ,c.ChurchAuthority
      ,c.SchoolSystem
      ,c.ParishName
--      ,c.ApprovedAuth -- all empty string commented out
      ,c.MissionStatement
      ,c.VisionStatement
      ,c.Motto
      ,c.WebAddress
--      ,c.fwLockUser -- all null commented out
--      ,c.fwLockTime -- all null commented out
      ,c.fwCreatedBy AS CreatedBy
      ,CONVERT(datetime,c.fwCreated,127) AS CreatedAt
      ,c.fwUpdatedBy AS UpdatedBy
      ,CONVERT(datetime,c.fwUpdated,127) AS UpdatedAt
FROM [silver].[Campus] AS c
LEFT JOIN [silver].[CampusType] AS t
ON c.Type = t.Type
ORDER BY c.Code